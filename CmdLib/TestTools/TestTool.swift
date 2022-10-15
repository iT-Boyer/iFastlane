//
//  TestTool.swift
//  CmdLib
//
//  Created by boyer on 2022/10/16.
//

import Foundation
import Fastlane

extension Fastfile{
    /**
     OVERVIEW: Build and run tests

     SEE ALSO: swift build, swift run, swift package

     USAGE: swift test <options>

     OPTIONS:
       --package-path <package-path>
                               Specify the package path to operate on (default
                               current directory). This changes the working
                               directory before any other operation
       --cache-path <cache-path>
                               Specify the shared cache directory path
       --config-path <config-path>
                               Specify the shared configuration directory path
       --security-path <security-path>
                               Specify the shared security directory path
       --scratch-path <scratch-path>
                               Specify a custom scratch directory path (default
                               .build)
       --enable-dependency-cache/--disable-dependency-cache
                               Use a shared cache when fetching dependencies
                               (default: true)
       --enable-build-manifest-caching/--disable-build-manifest-caching
                               (default: true)
       --manifest-cache <manifest-cache>
                               Caching mode of Package.swift manifests (shared:
                               shared cache, local: package's build directory, none:
                               disabled (default: shared)
       -v, --verbose           Increase verbosity to include informational output
       --very-verbose, --vv    Increase verbosity to include debug output
       --disable-sandbox       Disable using the sandbox when executing subprocesses
       --enable-netrc/--disable-netrc
                               Load credentials from a .netrc file (default: true)
       --netrc-file <netrc-file>
                               Specify the .netrc file path.
       --enable-keychain/--disable-keychain
                               Search credentials in macOS keychain (default: true)
       --resolver-fingerprint-checking <resolver-fingerprint-checking>
                               (default: strict)
       --enable-prefetching/--disable-prefetching
                               (default: true)
       --force-resolved-versions, --disable-automatic-resolution, --only-use-versions-from-resolved-file
                               Only use versions from the Package.resolved file and
                               fail resolution if it is out-of-date
       --skip-update           Skip updating dependencies from their remote during a
                               resolution
       --disable-scm-to-registry-transformation
                               disable source control to registry transformation
                               (default: disabled)
       --use-registry-identity-for-scm
                               look up source control dependencies in the registry
                               and use their registry identity when possible to help
                               deduplicate across the two origins (default: disabled)
       --replace-scm-with-registry
                               look up source control dependencies in the registry
                               and use the registry to retrieve them instead of
                               source control when possible (default: disabled)
       -c, --configuration <configuration>
                               Build with configuration (default: debug)
       -Xcc <Xcc>              Pass flag through to all C compiler invocations
       -Xswiftc <Xswiftc>      Pass flag through to all Swift compiler invocations
       -Xlinker <Xlinker>      Pass flag through to all linker invocations
       -Xcxx <Xcxx>            Pass flag through to all C++ compiler invocations
       --triple <triple>
       --sdk <sdk>
       --toolchain <toolchain>
       --sanitize <sanitize>   Turn on runtime checks for erroneous behavior,
                               possible values: address, thread, undefined, scudo
       --auto-index-store/--enable-index-store/--disable-index-store
                               Enable or disable indexing-while-building feature
                               (default: autoIndexStore)
       --enable-parseable-module-interfaces
       -j, --jobs <jobs>       The number of jobs to spawn in parallel during the
                               build process
       --emit-swift-module-separately
       --use-integrated-swift-driver
       --experimental-explicit-module-build
       --print-manifest-job-graph
                               Write the command graph for the build manifest as a
                               graphviz file
       --build-system <build-system>
                               (default: native)
       --enable-dead-strip/--disable-dead-strip
                               Disable/enable dead code stripping by the linker
                               (default: true)
       --static-swift-stdlib/--no-static-swift-stdlib
                               Link Swift stdlib statically (default: false)
       --skip-build            Skip building the test target
       --parallel              Run the tests in parallel.
       --num-workers <num-workers>
                               Number of tests to execute in parallel.
       -l, --list-tests        Lists test methods in specifier format
       --show-codecov-path     Print the path of the exported code coverage JSON file
       -s, --specifier <specifier>
       --filter <filter>       Run test cases matching regular expression, Format:
                               <test-target>.<test-case> or
                               <test-target>.<test-case>/<test>
       --skip <skip>           Skip test cases matching regular expression, Example:
                               --skip PerformanceTests
       --xunit-output <xunit-output>
                               Path where the xUnit xml file should be generated.
       --test-product <test-product>
                               Test the specified product.
       --enable-testable-imports/--disable-testable-imports
                               Enable or disable testable imports. Enabled by
                               default. (default: true)
       --enable-code-coverage/--disable-code-coverage
                               Enable code coverage (default: false)
       --version               Show the version.
       -h, -help, --help       Show help information.


     */
//    func swiftTestLane() {
//        
//        let args = [ RubyCommand.Argument(name: "package-path", value: ""),
//                      RubyCommand.Argument(name: "user_key", value: ""),
//                      RubyCommand.Argument(name: "update_description", value: desc)
//                   ]
//        let command = RubyCommand(commandID: "",
//                                  methodName: "swift test",
//                                  className: nil,
//                                  args: args)
//        _ = runner.executeCommand(command)
//    }
}
