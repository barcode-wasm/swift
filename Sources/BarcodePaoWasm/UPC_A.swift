// UPC_A.swift
// UPC-A barcode generator using WASM bridge.

import Foundation

/// Generates UPC-A barcodes via WASM.
public class UPCA: Barcode1DBase {

    /// Create a UPC-A barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "UPC_A")
        setOutputFormat(outputFormat)
    }

    /// Set whether to use extended guard bars.
    public func setExtendedGuard(_ ext: Bool) {
        settings["extendedGuard"] = AnyEncodable(ext)
    }
}
