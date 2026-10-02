// ITF.swift
// ITF (Interleaved 2 of 5) barcode generator using WASM bridge.

import Foundation

/// Generates ITF (Interleaved 2 of 5) barcodes via WASM.
public class ITF: Barcode1DBase {

    /// Create an ITF barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "ITF")
        setOutputFormat(outputFormat)
    }
}
