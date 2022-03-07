//
//  ZTTaskM.swift
//  CmdLib
//
//  Created by boyer on 2022/3/7.
//

import Foundation
struct ZTTaskM:Codable{
    //是    任务ID
    var id:Int?
    //是    所属项目
    var project:Int?
    //是    所属执行
    var execution:Int?
    //是    所属模块
    var module:Int?
    //是    关联需求
    var story:Int?
    //是    任务名称
    var name:String?
    //是    任务类型(design 设计 | devel 开发 | request 需求 | test 测试 | study 研究 | discuss 讨论 | ui 界面 | affair 事务 | misc 其他)
    var type:String?
    //是    优先级
    var pri:Int?
    //是    预计工时
    var estimate:Float?
    //是    剩余工时
    var left:Float?
    //是    截止日期
    var deadline:String?
    //是    消耗工时
    var consumed:Float?
    //是    状态(wait 未开始 | doing 进行中 | done 已完成 | closed 已关闭 | cancel 已取消)
    var status:String?
    //是    任务详情
    var desc:String?
    //是    创建人
    var openedBy:ZTUserM?
    //是    创建时间
    var openedDate:String?
    //是    指派给
    var assignedTo:ZTUserM?
    //是    预计开始日期
    var estStarted:String?
    //是    实际开始时间
    var realStarted:String?
    //否    由谁完成
    var finishedBy:ZTUserM?
    //否    完成时间
    var finishedDate:String?
    //否    由谁关闭
    var closedBy:ZTUserM?
    //否    关闭时间
    var closedDate:String?
    //否    抄送给
    var mailto:[String]?
    
    static func parsed<T:Decodable>(data:Data) -> T {
        do{
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        }catch{
            fatalError(#function+"解析失败：\(error)")
        }
    }
}
