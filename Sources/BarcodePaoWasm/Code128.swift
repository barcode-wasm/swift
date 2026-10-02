// Code128.swift
// Code128 barcode generator using WASM bridge.

import Foundation

/// Generates Code128 barcodes via WASM.
public class Code128: Barcode1DBase {

    /// Create a Code128 barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "Code128")
        setOutputFormat(outputFormat)
    }

    /// Set the code mode (AUTO, A, B, C).
    public func setCodeMode(_ mode: String) {
        settings["codeMode"] = AnyEncodable(mode)
    }
}
