// PDF417.swift
// PDF417 barcode generator using WASM bridge.

import Foundation

/// Generates PDF417 barcodes via WASM.
public class PDF417: Barcode2DBase {

    /// Create a PDF417 barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "PDF417")
        setOutputFormat(outputFormat)
    }

    /// Set the error correction level (-1 = auto, 0-8).
    public func setErrorLevel(_ level: Int) {
        settings["errorLevel"] = AnyEncodable(level)
    }

    /// Set the number of columns.
    public func setColumns(_ cols: Int) {
        settings["columns"] = AnyEncodable(cols)
    }

    /// Set the number of rows.
    public func setRows(_ rows: Int) {
        settings["rows"] = AnyEncodable(rows)
    }

    /// Set the aspect ratio.
    public func setAspectRatio(_ ratio: Double) {
        settings["aspectRatio"] = AnyEncodable(ratio)
    }

    /// Set the Y height.
    public func setYHeight(_ yHeight: Int) {
        settings["yHeight"] = AnyEncodable(yHeight)
    }

    /// Generate a PDF417 barcode (width x height).
    /// - Parameters:
    ///   - code: The barcode data string.
    ///   - width: Image width in pixels.
    ///   - height: Image height in pixels.
    /// - Returns: Base64 data URI (for PNG/JPEG) or SVG markup (for SVG format).
    public func draw(code: String, width: Int, height: Int) throws -> String {
        return try call(method: "draw", args: AnyEncodable(code), AnyEncodable(width), AnyEncodable(height))
    }
}
