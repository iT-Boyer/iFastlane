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
    func buildLibLane(projPath:String,target:String) {
        let outDir = "/Users/boyer/Desktop/libs"
//        let projPath = "/Users/boyer/hsg/jhgsguesslikeshoppinglistcomponent/JHGuessLikesCommodityListComponent/JHGuessLikesCommodityListComponent.xcodeproj"
        gym(project:.userDefined(projPath),
                  scheme: "\(target)",
         outputDirectory: outDir,
           configuration: "Debug",
//          skipPackageIpa: .userDefined(true),
             skipArchive: .userDefined(true),
         skipCodesigning: .userDefined(true),
            buildPath: .userDefined(outDir), //The directory in which the archive should be stored in
         derivedDataPath: .userDefined(outDir)
        )
    }
    
    
    //1. 获取库名称+lib名
    //2. 查找proj文件：find xcodeproj
    //3. xcodeproj工具，解析，获取target清单
    //4. 得到target
    //5. 调用gym脚本编译，在Desktop/libs得到.a文件
    //6. 归档：移动到最终目录
    //7. copy到主工程，并替换

}
