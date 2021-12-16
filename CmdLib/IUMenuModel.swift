//
//  IUMenuModel.swift
//  CmdLib
//
//  Created by boyer on 2021/12/16.
//

import Cocoa

struct IUMenuModel: Codable {
    var menus:[IUMenu]
}

struct IUMenu:Codable {
    let funcName:String     //功能名
    let ComponentName:String//组件名
    let funcCode:String     //功能code
    var menuName:String? = nil     //菜单名
    var menuNames:[String]? = []  //菜单名清单
}


