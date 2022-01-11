//
//  Student.swift
//  RuntimeCmdTests
//
//  Created by boyer on 2022/1/11.
//

import Foundation

struct Student{
    
    var id:String
    var name:String
    var age:Int
    
}

class Person:NSObject
{
    var id:String
    @objc var name:String
    var age:Int
    override init() {
        self.id = "2"
        self.name = ""
        self.age = 3
    }
}
