// DataMatrix.swift
// DataMatrix barcode generator using WASM bridge.

import Foundation

/// Generates DataMatrix barcodes via WASM.
public class DataMatrix: Barcode2DBase {

    /// Create a DataMatrix barcode generator.
    /// - Parameter outputFormat: Output format (use BarcodeFormat.png, .jpeg, or .svg).
    public init(outputFormat: String = BarcodeFormat.png) {
        super.init(className: "DataMatrix")
        setOutputFormat(outputFormat)
    }

    /// Set the code size (AUTO, 10x10, 12x12, 14x14, 16x16, 18x18, 20x20, 22x22, 24x24, 26x26,
    /// 32x32, 36x36, 40x40, 44x44, 48x48, 52x52, 64x64, 72x72, 80x80, 88x88, 96x96, 104x104,
    /// 120x120, 132x132, 144x144, 8x18, 8x32, 12x26, 12x36, 16x36, 16x48).
    public func setCodeSize(_ size: String) {
        settings["codeSize"] = AnyEncodable(size)
    }

    /// Set the encode scheme (AUTO, ASCII, C40, TEXT, X12, EDIFACT, BASE256).
    public func setEncodeScheme(_ scheme: String) {
        settings["encodeScheme"] = AnyEncodable(scheme)
    }
}
