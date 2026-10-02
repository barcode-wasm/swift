// NEC2of5.swift
// NEC 2 of 5 barcode generator using WASM bridge.

import Foundation

/// Generates NEC 2 of 5 barcodes via WASM.
public class NEC2of5: Barcode1DBase {

    /// Create a NEC 2 of 5 barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "NEC2of5")
        setOutputFormat(outputFormat)
    }
}
