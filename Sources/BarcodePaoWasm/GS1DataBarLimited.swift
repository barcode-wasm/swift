// GS1DataBarLimited.swift
// GS1 DataBar Limited barcode generator using WASM bridge.

import Foundation

/// Generates GS1 DataBar Limited barcodes via WASM.
public class GS1DataBarLimited: Barcode1DBase {

    /// Create a GS1 DataBar Limited barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "GS1DataBarLimited")
        setOutputFormat(outputFormat)
    }
}
