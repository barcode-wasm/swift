// Wrapper.swift
// Core WASM bridge for barcode generation via Node.js subprocess.
//
// Architecture:
//   Swift code -> JSON -> node _barcode_runner.mjs -> barcode.mjs -> WASM -> JSON -> Swift

import Foundation

// MARK: - Output Format Constants

/// Output format constants for barcode generation.
public enum BarcodeFormat {
    public static let png  = "png"
    public static let jpeg = "jpg"
    public static let svg  = "svg"
}

// MARK: - Errors

/// Errors that can occur during WASM barcode generation.
public enum BarcodeWasmError: Error, LocalizedError {
    case nodeNotFound
    case wasmDirectoryNotFound
    case executionFailed(String)
    case invalidJSON(String)
    case wasmError(String)
    case unexpectedResultType

    public var errorDescription: String? {
        switch self {
        case .nodeNotFound:
            return "Node.js is required for WASM barcode generation. Please install Node.js from https://nodejs.org/"
        case .wasmDirectoryNotFound:
            return "WASM directory not found. Ensure barcode.wasm and barcode.mjs are in the wasm/ directory."
        case .executionFailed(let msg):
            return "WASM execution failed: \(msg)"
        case .invalidJSON(let msg):
            return "Invalid JSON response: \(msg)"
        case .wasmError(let msg):
            return "WASM error: \(msg)"
        case .unexpectedResultType:
            return "Unexpected result type from WASM"
        }
    }
}

// MARK: - WASM Request / Response

/// JSON request sent to the Node.js barcode runner.
private struct WasmRequest: Encodable {
    let className: String
    let method: String
    let methodArgs: [AnyEncodable]
    let settings: [String: AnyEncodable]
}

/// JSON response received from the Node.js barcode runner.
private struct WasmResponse: Decodable {
    let result: String?
    let error: String?
}

/// Type-erased Encodable wrapper for heterogeneous JSON values.
public struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    public init<T: Encodable>(_ value: T) {
        _encode = { encoder in
            try value.encode(to: encoder)
        }
    }

    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

// MARK: - Node.js Detection

/// Cached Node.js path.
private var _cachedNodePath: String?
private var _nodePathResolved = false

/// Find the Node.js executable on the system.
private func findNode() throws -> String {
    if _nodePathResolved, let path = _cachedNodePath {
        return path
    }

    for cmd in ["node", "nodejs"] {
        let process = Process()
        #if os(Windows)
        process.executableURL = URL(fileURLWithPath: "C:\\Windows\\System32\\where.exe")
        process.arguments = [cmd]
        #else
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [cmd]
        #endif

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let path = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .components(separatedBy: .newlines)
                    .first?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                   !path.isEmpty {
                    _cachedNodePath = path
                    _nodePathResolved = true
                    return path
                }
            }
        } catch {
            continue
        }
    }

    _nodePathResolved = true
    throw BarcodeWasmError.nodeNotFound
}

// MARK: - WASM Directory Resolution

/// Find the wasm directory containing barcode.mjs and _barcode_runner.mjs.
private func getWasmDir() -> String? {
    // 1. Try Bundle.module (SPM resource bundle)
    #if SWIFT_PACKAGE
    let bundlePath = Bundle.module.resourcePath ?? Bundle.module.bundlePath
    let bundleWasm = (bundlePath as NSString).appendingPathComponent("wasm")
    if FileManager.default.fileExists(atPath: bundleWasm) {
        return bundleWasm
    }
    // Resources might be directly in the bundle path
    let runnerInBundle = (bundlePath as NSString).appendingPathComponent("_barcode_runner.mjs")
    if FileManager.default.fileExists(atPath: runnerInBundle) {
        return bundlePath
    }
    #endif

    // 2. Try relative to the source file location (development)
    let thisFile = #filePath
    let sourceDir = (thisFile as NSString).deletingLastPathComponent
    let devWasm = (sourceDir as NSString).appendingPathComponent("wasm")
    if FileManager.default.fileExists(atPath: devWasm) {
        return devWasm
    }

    // 3. Try relative to executable (distribution)
    if let execPath = Bundle.main.executablePath {
        let execDir = (execPath as NSString).deletingLastPathComponent
        let paths = [
            (execDir as NSString).appendingPathComponent("barcode_pao_wasm/wasm"),
            (execDir as NSString).appendingPathComponent("wasm"),
        ]
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
    }

    // 4. Fallback
    return "wasm"
}

// MARK: - WASM Call

/// Execute a WASM barcode operation via Node.js subprocess.
/// - Parameters:
///   - className: The C++ barcode class name (e.g. "Code39", "QR").
///   - method: The method to call (e.g. "draw").
///   - args: Method arguments as encodable values.
///   - settings: Configuration settings dictionary.
/// - Returns: The result string (base64 data URI or SVG markup).
func callWasm(
    className: String,
    method: String,
    args: [AnyEncodable],
    settings: [String: AnyEncodable]
) throws -> String {
    let node = try findNode()

    guard let wasmDir = getWasmDir() else {
        throw BarcodeWasmError.wasmDirectoryNotFound
    }

    let scriptPath = (wasmDir as NSString).appendingPathComponent("_barcode_runner.mjs")

    // Build request JSON
    let request = WasmRequest(
        className: className,
        method: method,
        methodArgs: args,
        settings: settings
    )

    let encoder = JSONEncoder()
    let requestData = try encoder.encode(request)
    guard let requestJSON = String(data: requestData, encoding: .utf8) else {
        throw BarcodeWasmError.invalidJSON("Failed to encode request")
    }

    // Launch Node.js process
    let process = Process()
    process.executableURL = URL(fileURLWithPath: node)
    process.arguments = [scriptPath, requestJSON]
    process.currentDirectoryURL = URL(fileURLWithPath: wasmDir)

    // SVG/PNG responses can exceed a pipe buffer. Spool both streams so the
    // child cannot block while the parent waits for its completion.
    let outputDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: outputDirectory) }
    let stdoutURL = outputDirectory.appendingPathComponent("stdout")
    let stderrURL = outputDirectory.appendingPathComponent("stderr")
    FileManager.default.createFile(atPath: stdoutURL.path, contents: nil)
    FileManager.default.createFile(atPath: stderrURL.path, contents: nil)
    let stdoutFile = try FileHandle(forWritingTo: stdoutURL)
    let stderrFile = try FileHandle(forWritingTo: stderrURL)
    defer { try? stdoutFile.close(); try? stderrFile.close() }
    process.standardOutput = stdoutFile
    process.standardError = stderrFile

    try process.run()
    process.waitUntilExit()

    let stdoutData = try Data(contentsOf: stdoutURL)
    let stderrData = try Data(contentsOf: stderrURL)
    let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
    let stderr = String(data: stderrData, encoding: .utf8) ?? ""

    if process.terminationStatus != 0 {
        // Try to parse JSON error from stdout
        if !stdout.isEmpty {
            if let resp = parseWasmResponse(stdout), let error = resp.error, !error.isEmpty {
                throw BarcodeWasmError.wasmError(error)
            }
        }
        if !stderr.isEmpty {
            throw BarcodeWasmError.executionFailed(stderr.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        throw BarcodeWasmError.executionFailed("exit code \(process.terminationStatus)")
    }

    // Find JSON line in output (may have debug output before it)
    let lines = stdout
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n")

    var jsonLine: String?
    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("{") && trimmed.hasSuffix("}") {
            jsonLine = trimmed
        }
    }

    guard let json = jsonLine else {
        throw BarcodeWasmError.invalidJSON("No JSON response from WASM output")
    }

    guard let resp = parseWasmResponse(json) else {
        throw BarcodeWasmError.invalidJSON(json)
    }

    if let error = resp.error, !error.isEmpty {
        throw BarcodeWasmError.wasmError(error)
    }

    guard let result = resp.result else {
        throw BarcodeWasmError.unexpectedResultType
    }

    return result
}

/// Parse a JSON string into a WasmResponse.
private func parseWasmResponse(_ json: String) -> WasmResponse? {
    guard let data = json.data(using: .utf8) else { return nil }
    return try? JSONDecoder().decode(WasmResponse.self, from: data)
}

// MARK: - BarcodeWasmBase

/// Base class for all WASM barcode types. Holds common settings.
open class BarcodeWasmBase {
    let className: String
    var settings: [String: AnyEncodable]

    init(className: String) {
        self.className = className
        self.settings = ["outputFormat": AnyEncodable(BarcodeFormat.png)]
    }

    /// Set the output format (png, jpg, svg).
    public func setOutputFormat(_ format: String) {
        settings["outputFormat"] = AnyEncodable(format)
    }

    /// Set the foreground color (RGBA, 0-255).
    public func setForegroundColor(r: Int, g: Int, b: Int, a: Int) {
        settings["foregroundColor"] = AnyEncodable([r, g, b, a])
    }

    /// Set the background color (RGBA, 0-255).
    public func setBackgroundColor(r: Int, g: Int, b: Int, a: Int) {
        settings["backgroundColor"] = AnyEncodable([r, g, b, a])
    }

    /// Call a WASM method with the given arguments.
    func call(method: String, args: AnyEncodable...) throws -> String {
        return try callWasm(
            className: className,
            method: method,
            args: args,
            settings: settings
        )
    }

    /// Get the generated image as a Base64 data URI string.
    /// Call draw() first, then retrieve the result.
    /// Note: draw() returns the result directly in this WASM wrapper.
    public func getImageBase64(code: String, args: AnyEncodable...) throws -> String {
        // This is handled by the draw() methods in subclasses
        fatalError("Use the draw() method on the specific barcode type instead")
    }
}

// MARK: - Barcode1DBase

/// Base class for 1D barcode types.
open class Barcode1DBase: BarcodeWasmBase {

    /// Set whether to show text below the barcode.
    public func setShowText(_ show: Bool) {
        settings["showText"] = AnyEncodable(show)
    }

    /// Set the gap between barcode and text.
    public func setTextGap(_ gap: Double) {
        settings["textGap"] = AnyEncodable(gap)
    }

    /// Set the text font scale.
    public func setTextFontScale(_ scale: Double) {
        settings["textFontScale"] = AnyEncodable(scale)
    }

    /// Set text even spacing mode.
    public func setTextEvenSpacing(_ even: Bool) {
        settings["textEvenSpacing"] = AnyEncodable(even)
    }

    /// Set whether to fit the barcode to width.
    public func setFitWidth(_ fit: Bool) {
        settings["fitWidth"] = AnyEncodable(fit)
    }

    /// Set pixel adjustment for black bars.
    public func setPxAdjustBlack(_ adj: Int) {
        settings["pxAdjustBlack"] = AnyEncodable(adj)
    }

    /// Set pixel adjustment for white bars.
    public func setPxAdjustWhite(_ adj: Int) {
        settings["pxAdjustWhite"] = AnyEncodable(adj)
    }

    /// Generate a 1D barcode and return a Base64 data URI or SVG string.
    /// - Parameters:
    ///   - code: The barcode data string.
    ///   - width: Image width in pixels.
    ///   - height: Image height in pixels.
    /// - Returns: Base64 data URI (for PNG/JPEG) or SVG markup (for SVG format).
    public func draw(code: String, width: Int, height: Int) throws -> String {
        return try call(method: "draw", args: AnyEncodable(code), AnyEncodable(width), AnyEncodable(height))
    }
}

// MARK: - Barcode2DBase

/// Base class for 2D barcode types.
open class Barcode2DBase: BarcodeWasmBase {

    /// Set the string encoding (utf-8, shift-jis).
    public func setStringEncoding(_ enc: String) {
        settings["stringEncoding"] = AnyEncodable(enc)
    }

    /// Set whether to fit the barcode to width.
    public func setFitWidth(_ fit: Bool) {
        settings["fitWidth"] = AnyEncodable(fit)
    }

    /// Generate a 2D barcode and return a Base64 data URI or SVG string.
    /// - Parameters:
    ///   - code: The barcode data string.
    ///   - size: Image size in pixels (width = height).
    /// - Returns: Base64 data URI (for PNG/JPEG) or SVG markup (for SVG format).
    public func draw(code: String, size: Int) throws -> String {
        return try call(method: "draw", args: AnyEncodable(code), AnyEncodable(size))
    }
}

// MARK: - Product Info

/// Get the product name.
public func getProductName() -> String { return "barcode-pao-wasm (Swift)" }

/// Get the version.
public func getVersion() -> String { return "1.2.1" }

/// Get the manufacturer.
public func getManufacturer() -> String { return "Pao" }

public enum ProductInfo {
 public static func getLicenseEmailAddr() throws -> String {
  try callWasm(className: "ProductInfo", method: "getLicenseEmailAddr", args: [], settings: [:])
 }
}
