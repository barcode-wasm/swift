// YubinCustomer.swift
// Japanese postal customer barcode generator using WASM bridge.

import Foundation

/// Generates Japanese postal customer barcodes via WASM.
public class YubinCustomer: BarcodeWasmBase {

    /// Create a YubinCustomer barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "YubinCustomer")
        setOutputFormat(outputFormat)
    }

    /// Set pixel adjustment for black bars.
    public func setPxAdjustBlack(_ adj: Int) {
        settings["pxAdjustBlack"] = AnyEncodable(adj)
    }

    /// Set pixel adjustment for white bars.
    public func setPxAdjustWhite(_ adj: Int) {
        settings["pxAdjustWhite"] = AnyEncodable(adj)
    }

    /// Generate a postal barcode. Width is auto-calculated.
    /// - Parameters:
    ///   - code: The postal code string (e.g. "264-0025-1-2-503").
    ///   - height: Image height in pixels.
    /// - Returns: Base64 data URI (for PNG/JPEG) or SVG markup (for SVG format).
    public func draw(code: String, height: Int) throws -> String {
        return try call(method: "draw", args: AnyEncodable(code), AnyEncodable(height))
    }

    /// Generate a postal barcode with explicit width.
    /// - Parameters:
    ///   - code: The postal code string.
    ///   - width: Image width in pixels.
    ///   - height: Image height in pixels.
    /// - Returns: Base64 data URI (for PNG/JPEG) or SVG markup (for SVG format).
    public func drawWithWidth(code: String, width: Int, height: Int) throws -> String {
        return try call(method: "drawWithWidth", args: AnyEncodable(code), AnyEncodable(width), AnyEncodable(height))
    }
}
