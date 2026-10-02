// Code39.swift
// Code39 barcode generator using WASM bridge.

import Foundation

/// Generates Code39 barcodes via WASM.
public class Code39: Barcode1DBase {

    /// Create a Code39 barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "Code39")
        setOutputFormat(outputFormat)
    }

    /// Set whether to show start/stop characters (*) in the barcode text.
    public func setShowStartStop(_ show: Bool) {
        settings["showStartStop"] = AnyEncodable(show)
    }
}
