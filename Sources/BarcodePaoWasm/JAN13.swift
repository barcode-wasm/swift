// JAN13.swift
// JAN-13 (EAN-13) barcode generator using WASM bridge.

import Foundation

/// Generates JAN-13 (EAN-13) barcodes via WASM.
public class JAN13: Barcode1DBase {

    /// Create a JAN-13 barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "Jan13")
        setOutputFormat(outputFormat)
    }

    /// Set whether to use extended guard bars.
    public func setExtendedGuard(_ ext: Bool) {
        settings["extendedGuard"] = AnyEncodable(ext)
    }
}
