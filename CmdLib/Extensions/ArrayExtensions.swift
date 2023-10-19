//
//  ArrayExtensions.swift
//  CmdLib
//
//  Created by boyer on 2022/3/1.
//

import Foundation
import Regex

extension Array {
    // 去重
    //let filterModels = bugArr.filterDuplicates({$0.name})
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
    
    // 去重
    func regexDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let tmpArr = result.filter { xx in
                let key:String = filter(value) as! String
                let key2:String = filter(xx) as! String
                let regex = Regex("(0[xX])?[a-fA-F0-9]+")
                let key_ = key.replacingFirst(matching: regex, with: "")
                let key2_ = key2.replacingFirst(matching: regex, with: "")
                return key_ == key2_
            }
            
            if tmpArr.count == 0  {
                result.append(value)
            }
        }
        return result
    }
}
