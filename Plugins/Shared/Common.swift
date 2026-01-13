import PackagePlugin
import Foundation

// MARK: - Process Execution

struct CBIOCommand {
    let subcommand: String
    let action: String
    let successMessage: String
    let errorMessage: String
}

func runCBIO(
    _ command: CBIOCommand,
    files: [String],
    arguments: [String],
    executable: URL
) throws {
    let process = Process()
    process.executableURL = executable

    process.arguments = [
        command.subcommand,
        command.action
    ] + arguments + files

    try process.run()
    process.waitUntilExit()

    if process.terminationReason == .exit && process.terminationStatus == 0 {
        print(command.successMessage)
    } else {
        let problem = "\(process.terminationReason):\(process.terminationStatus)"
        Diagnostics.error("\(command.errorMessage): \(problem)")
    }
}

// MARK: - File Collection

func collectFiles(from context: PluginContext) -> [String] {
    context.package.targets.compactMap { target -> [String]? in
        guard let sourceTarget = target as? SourceModuleTarget else { return nil }
        return sourceTarget.sourceFiles.map { $0.path.string }
    }.flatMap { $0 }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

func collectFiles(
    from context: XcodePluginContext,
    arguments: [String],
    excluding targets: Set<String>
) throws -> [String] {
    let projectTargets = arguments.projectTargets(excluding: targets)
    guard !projectTargets.isEmpty else {
        throw "No Xcode target specified"
    }

    var files: [String] = []
    for targetName in projectTargets {
        if let target = context.xcodeProject.targets.first(where: { $0.displayName == targetName }) {
            files += target.inputFiles.map { $0.path.string }
        }
    }
    return files
}
#endif

// MARK: - Argument Parsing

extension Array where Element == String {

    /// Extracts Xcode project target names from arguments, excluding command-specific targets.
    func projectTargets(excluding targets: Set<String>) -> [String] {
        var targetNames: [String] = []

        // Parse sequentially; do not assume `--arg value` pairs because some arguments are flags.
        var index = 0
        while index < self.count {
            if self[index] == "--target", index + 1 < self.count {
                let value = self[index + 1]
                if !targets.contains(value) {
                    targetNames.append(value)
                }
                index += 2
            } else {
                index += 1
            }
        }

        return targetNames
    }

    func filteredArguments(
        knownArguments: Set<String>,
        knownTargets: Set<String>,
        knownFileSearchStrategies: Set<String> = ["find", "fileManager"],
        additionalValueHandlers: [String: (String) -> String?] = [:]
    ) -> [String] {
        return self.enumerated().reduce(into: [String]()) { result, current in
            let (index, argument) = current

            guard knownArguments.contains(argument) else { return }

            if argument == "--target" {
                guard index + 1 < self.count else { return }
                let value = self[index + 1]
                guard knownTargets.contains(value) else { return }
                result.append(argument)
                result.append(value)
            } else if argument == "--file-search-strategy" {
                guard index + 1 < self.count else { return }
                let value = self[index + 1]
                guard knownFileSearchStrategies.contains(value) else { return }
                result.append(argument)
                result.append(value)
            } else if let handler = additionalValueHandlers[argument] {
                guard index + 1 < self.count else { return }
                let value = self[index + 1]
                if let processedValue = handler(value) {
                    result.append(argument)
                    result.append(processedValue)
                }
            } else {
                result.append(argument)
            }
        }
    }
}

// MARK: - String Error Conformance

#if hasFeature(RetroactiveAttribute)
extension String: @retroactive Error { }
#else
extension String: Error { }
#endif
