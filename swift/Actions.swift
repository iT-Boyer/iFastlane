import Foundation
import Fastlane
/**
 A short description with <= 80 characters of what this action does

 - parameters:
   - apiToken: API Token for ActspmAction
   - development: Create a development certificate instead of a distribution one

 You can use this action to do cool things...
*/
public func actspm(apiToken: String,
                   development: OptionalConfigValue<Bool> = .fastlaneDefault(false)) {
let apiTokenArg = RubyCommand.Argument(name: "api_token", value: apiToken, type: nil)
let developmentArg = development.asRubyArgument(name: "development", type: nil)
let array: [RubyCommand.Argument?] = [apiTokenArg,
developmentArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "actspm", className: nil, args: args)
  _ = runner.executeCommand(command)
}
