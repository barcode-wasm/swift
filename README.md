# Barcode.wasm for Swift

Swift から使えるバーコード生成ライブラリです（Swift Package Manager）。バーコードを作る本体は C++ の WebAssembly（`barcode.wasm`）で、Swift のコードは Node.js を通してそれを呼び出します。

- 対応：CODE39・CODE93・CODE128・GS1-128・NW7・ITF・Matrix 2of5・NEC 2of5・JAN-8・JAN-13・UPC-A・UPC-E・GS1 DataBar（標準・限定・拡張）・郵便カスタマーバーコード・QR コード・DataMatrix・PDF417
- 出力：PNG・JPEG・SVG（data URI の文字列）
- **体験版**です。画像に赤い「SAMPLE」が入ります。製品版は [Barcode.wasm](https://www.pao.ac/barcode.wasm/) をご覧ください。
- macOS と Linux のサーバー・コマンドライン向けです（Node.js を子プロセスとして起動するため、iOS では使えません）。

## 必要なもの

- Swift 5.10 以降
- Node.js 18 以降（`node` が PATH にあること）

## インストール

`Package.swift` に追加します。

```swift
dependencies: [
    .package(url: "https://github.com/barcode-wasm/swift.git", from: "1.2.0"),
],
targets: [
    .executableTarget(name: "App", dependencies: [
        .product(name: "BarcodePaoWasm", package: "swift"),
    ]),
]
```

## 使い方

```swift
import BarcodePaoWasm

let c = Code128(outputFormat: BarcodeFormat.png)
c.setShowText(true)
let png = try c.draw(code: "ABC123", width: 400, height: 120) // "data:image/png;base64,..."

let qr = QR(outputFormat: BarcodeFormat.svg)
let svg = try qr.draw(code: "https://www.pao.ac/", size: 300)
```

## ライセンス

MIT（[LICENSE](LICENSE)）

---

# Barcode.wasm for Swift (English)

A barcode generation library for Swift (Swift Package Manager). The barcode engine is a C++ WebAssembly module (`barcode.wasm`); the Swift code calls it through Node.js.

- Symbologies: CODE39, CODE93, CODE128, GS1-128, NW7 (Codabar), ITF, Matrix 2of5, NEC 2of5, JAN-8/EAN-8, JAN-13/EAN-13, UPC-A, UPC-E, GS1 DataBar (Omnidirectional, Limited, Expanded), Japan Post customer barcode, QR Code, DataMatrix, PDF417
- Output: PNG, JPEG, SVG (as a data URI string)
- This is a **trial edition**: images carry a red "SAMPLE" mark. See [Barcode.wasm](https://www.pao.ac/barcode.wasm/) for the product edition.
- For macOS and Linux servers and command-line tools (it starts Node.js as a child process, so it does not run on iOS).

## Requirements

- Swift 5.10 or later
- Node.js 18 or later (`node` on PATH)

## Install

```swift
.package(url: "https://github.com/barcode-wasm/swift.git", from: "1.2.0")
// target dependency:
.product(name: "BarcodePaoWasm", package: "swift")
```

## Usage

```swift
import BarcodePaoWasm

let c = Code128(outputFormat: BarcodeFormat.png)
c.setShowText(true)
let png = try c.draw(code: "ABC123", width: 400, height: 120) // "data:image/png;base64,..."
```

## License

MIT ([LICENSE](LICENSE))
