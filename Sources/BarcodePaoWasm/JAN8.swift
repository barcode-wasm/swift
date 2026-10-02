// JAN8.swift
// JAN-8 (EAN-8) barcode generator using WASM bridge.

import Foundation

/// Generates JAN-8 (EAN-8) barcodes via WASM.
public class JAN8: Barcode1DBase {

    /// Create a JAN-8 barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "Jan8")
        setOutputFormat(outputFormat)
    }

    /// Set whether to use extended guard bars.
    public func setExtendedGuard(_ ext: Bool) {
        settings["extendedGuard"] = AnyEncodable(ext)
    }
}
