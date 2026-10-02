// GS1DataBarExpanded.swift
// GS1 DataBar Expanded barcode generator using WASM bridge.

import Foundation

/// Generates GS1 DataBar Expanded barcodes via WASM.
public class GS1DataBarExpanded: Barcode1DBase {

    /// Create a GS1 DataBar Expanded barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "GS1DataBarExpanded")
        setOutputFormat(outputFormat)
    }

    /// Set the symbol type (UNSTACKED, STACKED).
    public func setSymbolType(_ symbolType: String) {
        settings["symbolType"] = AnyEncodable(symbolType)
    }

    /// Set the number of columns for the stacked version.
    public func setNoOfColumns(_ cols: Int) {
        settings["noOfColumns"] = AnyEncodable(cols)
    }
}
