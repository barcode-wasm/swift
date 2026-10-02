// UPC_E.swift
// UPC-E barcode generator using WASM bridge.

import Foundation

/// Generates UPC-E barcodes via WASM.
public class UPCE: Barcode1DBase {

    /// Create a UPC-E barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "UPC_E")
        setOutputFormat(outputFormat)
    }

    /// Set whether to use extended guard bars.
    public func setExtendedGuard(_ ext: Bool) {
        settings["extendedGuard"] = AnyEncodable(ext)
    }
}
