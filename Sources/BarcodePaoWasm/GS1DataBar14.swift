// GS1DataBar14.swift
// GS1 DataBar 14 barcode generator using WASM bridge.

import Foundation

/// Generates GS1 DataBar 14 barcodes via WASM.
public class GS1DataBar14: Barcode1DBase {

    /// Create a GS1 DataBar 14 barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "GS1DataBar14")
        setOutputFormat(outputFormat)
    }

    /// Set the symbol type (OMNIDIRECTIONAL, STACKED, STACKED_OMNIDIRECTIONAL).
    public func setSymbolType(_ symbolType: String) {
        settings["symbolType"] = AnyEncodable(symbolType)
    }
}
