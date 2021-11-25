// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation
import Fastlane

class Fastfile: LaneFile {
    
    // let iossdk = "iphoneos13.5" //xcodebuild -showsdks 查看当前支持的sdk清单
    let iossdk = "iphoneos14.4"
    let plus8 = "52eee8ae3cd6f61bdb77aa7551e3539fd755d023"
    let ipad  = "d22f8060709e390aaa4d36231b931c2d61a4173a"
    var appName = "金和" //如果是中文时，必须赋值，例如：金和
    var ipaName = "金和" //ipa名称,必须是英文或全拼
    let iPappDir = "../hugo/dotfiles/ipa"  // 不识别`~`字符：~/hsg/hugo
    var outDir = ""
    var ipaPath = ""
    
   //:MARK
    func beforeAll() {
        outDir = iPappDir+"/"+ipaName //\(iPappDir)/\(ipaName)"
        ipaPath = outDir + "" + ipaName + ".ipa" //\(outDir)/\(ipaName).ipa"
//        cocoapods(podfile:"./Podfile")
//        cocoapods()
    }
    
    func afterAll(currentLane: String) {
        //
        slack(message: "成功", slackUrl: "https://hooks.slack.com/services/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",success:true)
    }
    
    func onError(currentLane: String, errorInfo: String) {
        //
        slack(message: "chenggong", slackUrl: "https://hooks.slack.com/services/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",success:false)
    }
    
    /** 支持带参数的lane
        调用语法：fastlane [lane] key:value key2:value2
        终端调用：fastlane helloLane name:hsg say:hello
     */
    func helloLane(withOptions options:[String: String]?) {
        
        if let name = options?["name"], name == "hsg",
            let say:String = options?["say"], say.count > 0{
            // Only when submit is true
            echo(message: "：\(name)向你说：\(say)")
        }
    }
}

/**
 
 | workspace              | SupervisionSel.xcworkspace                   |
 | scheme                 | SupervisionSel                               |
 | clean                  | false                                        |
 | output_directory       | ./build                                      |
 | configuration          | Debug                                        |
 | silent                 | true                                         |
 | skip_package_ipa       | false                                        |
 | skip_package_pkg       | false                                        |
 | export_method          | development                                  |
 | export_xcargs          | -allowProvisioningUpdates                    |
 | result_bundle          | false                                        |
 | buildlog_path          | ~/Library/Logs/gym                           |
 | sdk                    | iphoneos13.5                                 |
 | skip_profile_detection | false                                        |
 | destination            | generic/platform=iOS                         |
 | output_name            | SupervisionSel                               |
 | build_path             | /Users/jhmac/Library/Developer/Xcode/Archiv  |
 |                        | es/2020-07-02                                |
 | xcode_path             | /Applications/Xcode.app
 */
