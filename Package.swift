// swift-tools-version:6.2
import PackageDescription

let package = Package(
  name: "what-is-my-ip",
  platforms: [
    .macOS(.v13)
  ],
  dependencies: [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "4.122.2")
  ],
  targets: [
    .executableTarget(
      name: "App",
      dependencies: [
        .product(name: "Vapor", package: "vapor")
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: [
        .target(name: "App"),
        .product(name: "VaporTesting", package: "vapor"),
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
