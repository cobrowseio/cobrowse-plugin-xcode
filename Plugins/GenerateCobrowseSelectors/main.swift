import PackagePlugin
import Foundation

@main
struct CBIOGenerateSelectorPlugin: CommandPlugin {

    func performCommand(context: PluginContext, arguments: [String]) throws {

        let tool = try context.tool(named: "cbio")
        let cbio = URL(fileURLWithPath: tool.path.string)

        let files = context.package.targets.compactMap { target -> [String]? in
            guard let sourceTarget = target as? SourceModuleTarget
                else { return nil }

            return sourceTarget.sourceFiles.map { $0.path.string }
        }.flatMap { $0 }

        try process([files.first!], with: arguments, using: cbio)
    }
}

#if canImport (XcodeProjectPlugin)
import XcodeProjectPlugin

extension CBIOGenerateSelectorPlugin: XcodeCommandPlugin {
    func performCommand (context: XcodePluginContext, arguments: [String]) throws {

        let tool = try context.tool(named: "cbio")
        let cbio = URL(fileURLWithPath: tool.path.string)

        var files: [String] = []

        guard arguments.count >= 2, arguments.contains("--target")
            else { throw "No target specified" }

        for targetName in arguments.projectTargets {
            if let target = context.xcodeProject.targets.first(where: { $0.displayName == targetName }) {
                files += target.inputFiles.map { $0.path.string }
            }
        }

        try process(files, with: arguments, using: cbio)
    }
}
#endif

private func process(_ files: [String], with arguments: [String], using executable: URL) throws {

    let process = Process()
    process.executableURL = executable

    process.arguments = [
        "selector",
        "generate"
    ] + arguments.knownArguments + files

    try process.run()

    process.waitUntilExit()

    if process.terminationReason == .exit && process.terminationStatus == 0 {
        print("Successfully generated redaction selectors")
    }
    else {
        let problem = "\(process.terminationReason):\(process.terminationStatus)"
        Diagnostics.error("Failed to generate redaction selectors: \(problem)")
    }
}

extension Array where Element == String {

    var knownArguments: [String] {
        let knownArgumentsSet: Set<String> = [
            "--verbose",
            "--dry-run",
            "--known-views",
            "--validate",
            "--target",
            "--disable",
            "--include",
            "--ignore",
            "--default-attributes",
            "--source"
        ]
        
        let knownTargets: Set<String> = [
            "tags",
            "ids",
            "accessibilityIdentifiers"
        ]

        return self.enumerated().reduce(into: [String]()) { result, current in
            let (index, argument) = current
            
            guard knownArgumentsSet.contains(argument)
                else { return }
            
            if argument == "--target" {
                guard index + 1 < self.count
                    else { return }
                
                let value = self[index + 1]
                
                guard knownTargets.contains(value)
                    else { return }
                
                result.append(argument)
                result.append(value)
            } else if argument == "--default-attributes" {
                guard index + 1 < self.count
                else { return }
                
                let value = self[index + 1]
                
                result.append(argument)
                result.append(value)
            } else {
                result.append(argument)
            }
        }
    }

    var projectTargets: [String] {
        var targetNames = [String]()

        for index in stride(from: 0, to: self.count, by: 2) {
            if self[index] == "--target", index + 1 < self.count {
                targetNames.append(self[index + 1])
            }
        }

        return targetNames
    }
}

#if hasFeature(RetroactiveAttribute)
extension String: @retroactive Error { }
#else
extension String: Error { }
#endif
