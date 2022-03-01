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
                return Regex(":(Attempt|Modifications|CALayer|Set contentURL|.*?being enumerated)").matches(key)
            }
            if tmpArr.count == 0  {
                result.append(value)
            }
        }
        return result
    }
}
