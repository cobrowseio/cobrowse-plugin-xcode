// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CobrowseIOPlugin",
    platforms: [
        .macOS(.v10_13), .iOS(.v12)
    ],
    products: [
        .executable(name: "cbio",
                    targets: ["cbio-cli"]),
        .plugin(name: "CobrowseSelectorsPlugin",
                targets: ["GenerateCobrowseSelectors"])
    ],
    targets: [
        .plugin(
            name: "GenerateCobrowseSelectors",
            capability: .command(
                intent: .custom(
                    verb: "generate-cobrowse-selectors",
                    description: "Generate Cobrowse.io selectors"),
            permissions: [
                .writeToPackageDirectory(reason: "We need to modify your source to add the Cobrowse.io selectors.")
            ]),
            dependencies: [ "cbio-cli" ]
        ),
        .binaryTarget(
            name: "cbio-cli",
            path: "./cbio.artifactbundle"
        ),
    ]
)
