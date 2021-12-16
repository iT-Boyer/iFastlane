//
//  IUMenuModel.swift
//  CmdLib
//
//  Created by boyer on 2021/12/16.
//

import Cocoa

struct IUMenuModel: Codable {
    let iuMenus:[IUMenus]
    struct IUMenus:Codable {
        let funcName:String     //功能名
        let funcCode:String     //功能code
        let menuName:String     //菜单名
        let ComponentName:String//组件名
    }
  }
