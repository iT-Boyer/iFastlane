//
//  FastLaneCmds.swift
//  Runner
//
//  Created by boyer on 2021/12/6.
//

import Foundation
import Fastlane

extension Fastfile
{
    //编译静态库，指定生成路径
    // fastlane lane me
    func MeLibLane() {
        let outDir = "/Users/boyer/Desktop/libs"
        let projPath = "/Users/boyer/hsg/jhgsguesslikeshoppinglistcomponent/JHGuessLikesCommodityListComponent/JHGuessLikesCommodityListComponent.xcodeproj"
        buildApp(project:OptionalConfigValue.init(stringLiteral:projPath),
                  scheme: "JHUniversalApp",
       outputDirectory: outDir,
           configuration: "Debug"
        )
    }
}
