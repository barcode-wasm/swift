// QR.swift
// QR Code generator using WASM bridge.

import Foundation

/// Generates QR codes via WASM.
public class QR: Barcode2DBase {

    /// Create a QR code generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "QR")
        setOutputFormat(outputFormat)
    }

    /// Set the error correction level (L, M, Q, H).
    public func setErrorCorrectionLevel(_ level: String) {
        settings["errorCorrectionLevel"] = AnyEncodable(level)
    }

    /// Set QR version (0 = auto, 1-40).
    public func setVersion(_ version: Int) {
        settings["version"] = AnyEncodable(version)
    }

    /// Set the encode mode (NUMERIC, ALPHANUMERIC, BYTE, KANJI).
    public func setEncodeMode(_ mode: String) {
        settings["encodeMode"] = AnyEncodable(mode)
    }
}
