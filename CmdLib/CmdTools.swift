//
//  Tools.swift
//  Runner
//
//  Created by boyer on 2021/12/3.
//

import Foundation

public class CmdTools:NSObject {
    //给两个数组，求：两个数组不相同的元素数组
    public func arrDiff(arr1:[Substring], arr2:[Substring]) -> [Substring] {
        //转为set集合类型
        let set1 = Set(arr1)
        let set2 = Set(arr2)
        let diff = set1.symmetricDifference(set2)
        return Array(diff)
    }
    
    
}
