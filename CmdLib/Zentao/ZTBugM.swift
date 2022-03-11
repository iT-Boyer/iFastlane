//
//  ZTBugM.swift
//  AEXML
//
//  Created by boyer on 2022/3/7.
//

import Foundation

class ZTAddBugM:Codable {
    ///是    所属产品
    var product:Int?
    //是    所属项目
    var project:Int?
    //是    所属分支
    var branch:Int?
    //是    所属模块
    var module:Int?
    //是    所属执行
    var execution:Int?
    //是    Bug标题
    var title:String?
    //是    关键字
    var keywords:String?
    //是    严重程度
    var severity:Int? = 3
    //是    优先级
    var pri:Int? = 3
    //是    Bug类型(codeerror 代码错误 | config 配置相关 | install 安装部署 | security 安全相关 | performance 性能问题 | standard 标准规范 | automation |测试脚本 | designdefect 设计缺陷 | others 其他)
    var type:String? = "codeerror"
    //否    操作系统
    var os:String? = "iOS"
    //否    浏览器
    var browser:String?
    //是    重现步骤
    var steps:String?
    //否    相关任务
    var task:Int?
    //否    相关需求
    var story:Int?
    //否    截止日期
    var deadline:String?
    //否    影响版本
    var openedBuild:String?
    
    static func parsed<T:Decodable>(data:Data) -> T {
        do{
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        }catch{
            fatalError(#function+"解析失败：\(error)")
        }
    }
}

class ZTBugMBase:ZTAddBugM {
    ///是    Bug ID
    var id:Int?
    //是    转为任务
    var toTask:Int?
    //是    转为需求
    var toStory:Int?
    //是    创建时间
    var openedDate:String?
    //否    指派时间
    var assignedDate:String?
    //否    解决时间
    var resolvedDate:String?
    //否    解决版本
    var resolvedBuild:String?
    //否    关闭时间
    var closedDate:String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        toTask = try container.decode(Int?.self, forKey: .toTask)
        toStory = try container.decode(Int?.self, forKey: .toStory)
        openedDate = try container.decode(String?.self, forKey: .openedDate)
        assignedDate = try container.decode(String?.self, forKey: .assignedDate)
        resolvedDate = try container.decode(String?.self, forKey: .resolvedDate)
        resolvedBuild = try container.decode(String?.self, forKey: .resolvedBuild)
        closedDate = try container.decode(String?.self, forKey: .closedDate)
        try super.init(from: decoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case product
        case project
        case toTask
        case toStory
        case openedDate
        case assignedDate
        case resolvedDate
        case resolvedBuild
        case closedDate
    }
}

class ZTBugMV1:ZTBugMBase {
    //是    创建人
    var openedBy:ZTUserM?
    //否    指派给
    var assignedTo:ZTUserM?
    //否    由谁关闭
    var closedBy:ZTUserM?
    //否    由谁解决
    var resolvedBy:ZTUserM?
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        openedBy = try container.decode(ZTUserM?.self, forKey: .openedBy)
        assignedTo = try container.decode(ZTUserM?.self, forKey: .assignedTo)
        closedBy = try container.decode(ZTUserM?.self, forKey: .closedBy)
        resolvedBy = try container.decode(ZTUserM?.self, forKey: .resolvedBy)
        try super.init(from: decoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case openedBy
        case assignedTo
        case closedBy
        case resolvedBy
    }
}

class ZTBugM:ZTBugMBase {
    //是    创建人
    var openedBy:String?
    //否    指派给
    var assignedTo:String?
    //否    由谁关闭
    var closedBy:String?
    //否    由谁解决
    var resolvedBy:String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        openedBy = try container.decode(String?.self, forKey: .openedBy)
        assignedTo = try container.decode(String?.self, forKey: .assignedTo)
        closedBy = try container.decode(String?.self, forKey: .closedBy)
        resolvedBy = try container.decode(String?.self, forKey: .resolvedBy)
        try super.init(from: decoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case openedBy
        case assignedTo
        case closedBy
        case resolvedBy
    }
}
