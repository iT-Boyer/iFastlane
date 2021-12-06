//
//  main.swift
//  iFastlane
//
//  Created by boyer on 2021/11/25.
//

import Foundation
import Fastlane
import CmdLib
let ipFiles = ipFile()
print("Hello, world!")

//let iuooooPath = "/Users/boyer/Desktop/result-urls.json"
//let projDics = ipFiles.loadJsonData(path: iuooooPath, proj: "JHBluetoothLibrary")
//print(projDics)
//ipFiles.fetchSource()

Main().run(with: Fastfile())
