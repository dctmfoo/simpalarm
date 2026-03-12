// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SimpAlarm",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "SimpAlarm",
            targets: ["SimpAlarm"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "SimpAlarm",
            resources: [
                .process("Resources"),
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("Carbon"),
                .linkedFramework("ServiceManagement"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("UserNotifications"),
            ]
        ),
    ]
)
