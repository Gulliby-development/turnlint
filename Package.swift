// swift-tools-version: 6.2
import PackageDescription

let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
  name: "turnlint",
  targets: [
    .target(name: "TurnlintCore", swiftSettings: strict),
    .executableTarget(name: "turnlint", dependencies: ["TurnlintCore"], swiftSettings: strict),
    .testTarget(name: "TurnlintCoreTests", dependencies: ["TurnlintCore"], swiftSettings: strict),
  ]
)
