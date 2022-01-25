// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CellularAutomataSimulator",
    products: [
        .library(
            name: "CellularAutomataSimulator",
            targets: ["CellularAutomataSimulator"])
    ],
    targets: [
        .target(
            name: "CellularAutomataSimulator",
            dependencies: []),
        .testTarget(
            name: "CellularAutomataSimulatorTests",
            dependencies: ["CellularAutomataSimulator"])
    ]
)
