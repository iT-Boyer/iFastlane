import Fastlane
public class Matchfile: MatchfileProtocol {
    public var type: String { return "development" } // The default type, can be: appstore, adhoc, enterprise or development
    public var appIdentifier: [String] { return ["com.jinher.jingquezhili"] }
    public var username:String { return "724987481@qq.com" } // Your Apple Developer Portal username
    public var force: Bool{return true}
    public var forceForNewDevices: Bool{return true}
}

// For all available options run `fastlane match --help`
// Remove the // in the beginning of the line to enable the other options
