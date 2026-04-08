// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CobrowseIO Plugins",
    platforms: [
        .macOS(.v10_13), .iOS(.v12)
    ],
    products: [
        .executable(name: "cbio",
                    targets: ["cbio-cli"]),
        .plugin(name: "Generate Accessibility Identifiers",
                targets: [
                    "Generate Accessibility Identifiers"
                ]),
        .plugin(name: "Generate Cobrowse Selectors",
                targets: [
                    "Generate Cobrowse Selectors",
                ])
    ],
    targets: [
        .plugin(
            name: "Generate Accessibility Identifiers",
            capability: .command(
                intent: .custom(
                    verb: "generate-accessibility-identifiers",
                    description: "Generate structure based accessibility identifiers"),
                permissions: [
                    .writeToPackageDirectory(reason: "We need to modify your source to add the generated accessibility identifiers.")
                ]),
            dependencies: [ "cbio-cli" ],
            path: "Plugins/GenerateAccessibilityIdentifiers"
        ),
        .plugin(
            name: "Generate Cobrowse Selectors",
            capability: .command(
                intent: .custom(
                    verb: "generate-cobrowse-selectors",
                    description: "Generate Cobrowse.io selectors"),
                permissions: [
                    .writeToPackageDirectory(reason: "We need to modify your source to add the Cobrowse.io selectors.")
                ]),
            dependencies: [ "cbio-cli" ],
            path: "Plugins/GenerateCobrowseSelectors"
        ),
        .binaryTarget(
            name: "cbio-cli",
            path: "./cbio.artifactbundle"
        ),
    ]
)
