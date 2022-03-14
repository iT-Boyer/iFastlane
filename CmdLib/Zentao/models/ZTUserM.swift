//
//  ZTUserM.swift
//  CmdLib
//
//  Created by boyer on 2022/3/7.
//

import Foundation
struct ZTUserM:Codable{
    //是    用户编号
    var id:Int?
    //是    所属部门
    var dept:Int?
    //是    用户名
    var account:String?
    //是    真实姓名
    var realname:String?
    //否    角色
    var role:String?
    //否    邮箱
    var email:String?
    
    static func parsed<T:Decodable>(data:Data) -> T {
        do{
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        }catch{
            fatalError(#function+"解析失败：\(error)")
        }
    }
}
