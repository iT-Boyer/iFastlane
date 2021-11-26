import Foundation
/**
 distribute app to pgyer beta testing service

 - parameters:
   - apiKey: api_key in your pgyer account
   - userKey: user_key in your pgyer account
   - apk: Path to your APK file
   - ipa: Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action. For Mac zip the .app. For Android provide path to .apk file
   - password: set password to protect app
   - updateDescription: set update description for app
   - installType: set install type for app (1=public, 2=password, 3=invite). Please set as a string

 distribute app to pgyer beta testing service
*/
public func pgyer(apiKey: String,
                  userKey: String,
                  apk: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                  ipa: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                  password: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                  updateDescription: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                  installType: OptionalConfigValue<String?> = .fastlaneDefault(nil)) {
let apiKeyArg = RubyCommand.Argument(name: "api_key", value: apiKey, type: nil)
let userKeyArg = RubyCommand.Argument(name: "user_key", value: userKey, type: nil)
let apkArg = apk.asRubyArgument(name: "apk", type: nil)
let ipaArg = ipa.asRubyArgument(name: "ipa", type: nil)
let passwordArg = password.asRubyArgument(name: "password", type: nil)
let updateDescriptionArg = updateDescription.asRubyArgument(name: "update_description", type: nil)
let installTypeArg = installType.asRubyArgument(name: "install_type", type: nil)
let array: [RubyCommand.Argument?] = [apiKeyArg,
userKeyArg,
apkArg,
ipaArg,
passwordArg,
updateDescriptionArg,
installTypeArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "pgyer", className: nil, args: args)
  _ = runner.executeCommand(command)
}
