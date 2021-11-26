//
//  iPapp.swift
//  FastlaneRunner
//
//  Created by jhmac on 2020/7/2.
//  Copyright © 2020 Joshua Liebowitz. All rights reserved.
//

import Foundation
import Fastlane

extension Fastfile
{
    func iPappLane() {
       desc("发布到iPaapp库中....")
       echo(message: "发布---\(appName)")
       //执行shell命令 ./hsg/hugo/iPapp/iPapp.sh Blink BlinkName
       sh(command: "\(iPappDir)/iPapp.sh \(ipaPath)", log:true)
   }
   
   func uploadIPApp() {
       
   }
}
