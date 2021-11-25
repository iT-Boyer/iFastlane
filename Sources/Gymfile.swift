// For more information about this configuration visit
// https://docs.fastlane.tools/actions/gym/#gymfile

// In general, you can use the options available
// fastlane gym --help

// Remove the // in front of the line to enable the option
import Fastlane
public class Gymfile: GymfileProtocol {
//    var sdk: String { return "iphoneos13.0" }
//    var scheme: String { return "JHUniversalApp" }
//    var project:String {return nil}  //必须返回nil
//    var workspace:String{return "../YGPatrol.xcworkspace"}
    public var silent:Bool{return true}
    public var configuration:String{return "Debug"}
    public var exportMethod:String{return "development"}
    public var outputDirectory: String { return "./build" }
}
