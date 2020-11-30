// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "EasyAnimation",
    platforms: [
        .macOS(.v10_15), .iOS(.v8), .tvOS(.v9)
    ],
    products: [
        .library(name: "EasyAnimation", targets: ["EasyAnimation"])
    ],
    targets: [
        .target(name: "EasyAnimation", 
        		dependencies: [], 
        		path: "EasyAnimation"),
    ]
)
