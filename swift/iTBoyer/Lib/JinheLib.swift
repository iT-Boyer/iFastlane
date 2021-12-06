//
//  JinheLib.swift
//  Runner
//
//  Created by boyer on 2021/12/6.
//

import Foundation
import Fastlane

extension Fastfile
{
    //编译静态库，指定生成路径
    //xcodebuild -target ${target_Name} -configuration ${development_mode} -sdk iphonesimulator
    func buildLibLane() {
        let outDir = "/Users/boyer/Desktop/libs"
        let projPath = "/Users/boyer/hsg/jhgsguesslikeshoppinglistcomponent/JHGuessLikesCommodityListComponent/JHGuessLikesCommodityListComponent.xcodeproj"
        gym(project:OptionalConfigValue.init(stringLiteral:projPath),
                  scheme: "JHGuessLikesCommodityLibrary",
         outputDirectory: outDir,
           configuration: "Debug"
        )
        
        createXcframework(frameworks: <#T##OptionalConfigValue<[String]>?#>, frameworksWithDsyms: <#T##OptionalConfigValue<[String : Any]>?#>, libraries: <#T##OptionalConfigValue<[String]>?#>, librariesWithHeadersOrDsyms: <#T##OptionalConfigValue<[String : Any]>?#>, output: <#T##String#>, allowInternalDistribution: <#T##OptionalConfigValue<Bool>#>)
    }
}
