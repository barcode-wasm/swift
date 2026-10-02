// GS1_128.swift
// GS1-128 barcode generator using WASM bridge.

import Foundation

/// Generates GS1-128 barcodes via WASM.
public class GS1128: Barcode1DBase {

    /// Create a GS1-128 barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "GS1_128")
        setOutputFormat(outputFormat)
    }
}
