import PackagePlugin
import Foundation

@main
struct CBIOGenerateSelectorPlugin: CommandPlugin {

    func performCommand(context: PluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "cbio")
        let cbio = URL(fileURLWithPath: tool.path.string)
        let files = collectFiles(from: context)

        try process(files, with: arguments, using: cbio)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension CBIOGenerateSelectorPlugin: XcodeCommandPlugin {

    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "cbio")
        let cbio = URL(fileURLWithPath: tool.path.string)
        let files = try collectFiles(from: context, arguments: arguments, excluding: targets)

        try process(files, with: arguments, using: cbio)
    }
}
#endif

// MARK: - Command Configuration

private let command = CBIOCommand(
    subcommand: "selector",
    action: "generate",
    successMessage: "Successfully generated redaction selectors",
    errorMessage: "Failed to generate redaction selectors"
)

private let knownArgumentsSet: Set<String> = [
    "--comment-after",
    "--comment-before",
    "--default-attributes",
    "--disable",
    "--dry-run",
    "--file-search-strategy",
    "--ignore",
    "--ignore-variables",
    "--include",
    "--indent",
    "--known-views",
    "--source",
    "--target",
    "--validate",
    "--verbose"
]

private let knownTargets: Set<String> = [
    "tags",
    "ids",
    "accessibilityIdentifiers"
]

private let targets: Set<String> = [
    "tags",
    "ids",
    "accessibilityIdentifiers"
]

private func process(_ files: [String], with arguments: [String], using executable: URL) throws {
    let filteredArgs = arguments.filteredArguments(
        knownArguments: knownArgumentsSet,
        knownTargets: knownTargets,
        additionalValueHandlers: [
            "--default-attributes": { value in value }
        ]
    )
    try runCBIO(command, files: files, arguments: filteredArgs, executable: executable)
}
