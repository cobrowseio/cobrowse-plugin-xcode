import PackagePlugin
import Foundation

@main
struct CBIOGenerateAccessibilityIdentifiersPlugin: CommandPlugin {

    func performCommand(context: PluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "cbio")
        let cbio = URL(fileURLWithPath: tool.path.string)
        let files = collectFiles(from: context)

        try process(files, with: arguments, using: cbio)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension CBIOGenerateAccessibilityIdentifiersPlugin: XcodeCommandPlugin {

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
    subcommand: "accessibility",
    action: "generate",
    successMessage: "Successfully generated accessibility identifiers",
    errorMessage: "Failed to generate accessibility identifiers"
)

private let knownArgumentsSet: Set<String> = [
    "--comment-after",
    "--comment-before",
    "--disable",
    "--dry-run",
    "--file-search-strategy",
    "--ignore",
    "--ignore-variables",
    "--include",
    "--indent",
    "--known-views",
    "--postfix",
    "--prefix",
    "--source",
    "--target",
    "--validate",
    "--verbose"
]

private let knownTargets: Set<String> = [
    "identifiers"
]

private let targets: Set<String> = [
    "identifiers"
]

private func process(_ files: [String], with arguments: [String], using executable: URL) throws {
    let filteredArgs = arguments.filteredArguments(
        knownArguments: knownArgumentsSet,
        knownTargets: knownTargets
    )
    try runCBIO(command, files: files, arguments: filteredArgs, executable: executable)
}
