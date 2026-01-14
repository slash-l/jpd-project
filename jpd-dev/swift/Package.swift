// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "swift-app",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .executable(name: "swift-app", targets: ["swift-app"])
    ],
    dependencies: [
        // 添加明确有 CVE 的库版本用于测试 JFrog 检测能力
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", "4.0.0"..<"4.9.1") // CVE-2019-5483 等
        // .package(url: "https://github.com/onevcat/Kingfisher.git", "4.0.0"..<"5.0.0"), // CVE-2019-15605
        // .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", "3.0.0"..<"4.0.0"), // CVE-2017-16028
        // .package(url: "https://github.com/daltoniam/Starscream.git", "2.0.0"..<"3.0.0"), // 有已知安全问题
        // .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", "0.15.0"..<"1.0.0"), // CVE-2018-12030
        // // .package(url: "https://github.com/Alamofire/Alamofire.git", from: "3.0.0"), // 明确指定有漏洞的版本
        // .package(url: "https://github.com/realm/SwiftLint.git", from: "0.25.0") // 工具库

        // JFrog 官方 wiki example dependencies
        // .package(id: "apple.swift-nio", from: "2.65.0"),
        // .package(id: "vapor.fluent", from: "4.8.0"),
        // .package(id: "pointfreeco.swift-composable-architecture", from: "1.10.0"),
        // .package(id: "google.swift-protobuf", from: "1.27.0")
    ],
    targets: [
        .executableTarget(
            name: "swift-app",
            dependencies: [
                "Alamofire"
                // "SnapKit", 
                // "Kingfisher",
                // "RxSwift",
                // "SwiftyJSON"
            ],
            path: "Sources/swiftapp"
        )
    ]
)
