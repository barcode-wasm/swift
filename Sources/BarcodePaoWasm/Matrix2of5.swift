// Matrix2of5.swift
// Matrix 2 of 5 barcode generator using WASM bridge.

import Foundation

/// Generates Matrix 2 of 5 barcodes via WASM.
public class Matrix2of5: Barcode1DBase {

    /// Create a Matrix 2 of 5 barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "Matrix2of5")
        setOutputFormat(outputFormat)
    }
}
