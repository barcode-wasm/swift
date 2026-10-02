// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "barcode-pao-wasm",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "BarcodePaoWasm", targets: ["BarcodePaoWasm"]),
    ],
    targets: [
        .target(name: "BarcodePaoWasm",
            resources: [
                .copy("wasm/barcode.wasm"),
                .copy("wasm/barcode.js"),
                .copy("wasm/barcode.mjs"),
                .copy("wasm/_barcode_runner.mjs"),
            ]),
    ]
)
