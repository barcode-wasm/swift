// NW7.swift
// NW-7 (Codabar) barcode generator using WASM bridge.

import Foundation

/// Generates NW-7 (Codabar) barcodes via WASM.
public class NW7: Barcode1DBase {

    /// Create a NW-7 barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "NW7")
        setOutputFormat(outputFormat)
    }

    /// Set whether to show start/stop characters in the barcode text.
    public func setShowStartStop(_ show: Bool) {
        settings["showStartStop"] = AnyEncodable(show)
    }
}
