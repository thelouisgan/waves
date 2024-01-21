// swift-tools-version: 5.8

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "waves",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "waves",
            targets: ["AppModule"],
            bundleIdentifier: "com.ganlouis.waves",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .note),
            accentColor: .presetColor(.red),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit.git", "5.6.3"..<"6.0.0"),
        .package(url: "https://github.com/AudioKit/AudioKitEX.git", "5.6.0"..<"6.0.0"),
        .package(url: "https://github.com/AudioKit/Keyboard.git", "1.3.7"..<"2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "AudioKit", package: "audiokit"),
                .product(name: "AudioKitEX", package: "audiokitex"),
                .product(name: "Keyboard", package: "keyboard")
            ],
            path: "."
        )
    ]
)