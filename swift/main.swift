//
//  main.swift
//  iFastlane
//
//  Created by boyer on 2021/11/25.
//

import Foundation
import Fastlane

//let iuooooPath = "/Users/boyer/Desktop/result-urls.json"
//let projDics = ipFiles.loadJsonData(path: iuooooPath, proj: "JHBluetoothLibrary")
//print(projDics)
//ipFiles.fetchSource()

//http://docs.fastlane.tools/getting-started/ios/fastlane-swift/#getting-started-with-fastlaneswift-beta
//Add an entry point (@main) or a main.swift file (mandatory for executable SPM packages) and don't forget to start the fastlane runloop as follows:
Main().run(with: Fastfile())
