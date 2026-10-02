// Code93.swift
// Code93 barcode generator using WASM bridge.

import Foundation

/// Generates Code93 barcodes via WASM.
public class Code93: Barcode1DBase {

    /// Create a Code93 barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "Code93")
        setOutputFormat(outputFormat)
    }
}
