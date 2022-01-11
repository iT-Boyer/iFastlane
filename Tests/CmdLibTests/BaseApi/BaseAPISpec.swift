//
//  BaseAPISpec.swift
//  iWorker
//
//  Created by boyer on 2022/1/11.
//  
//
import Foundation
import Quick
import Nimble

class BaseAPISpec: QuickSpec {
    override func spec() {
        describe("验证筛选对象数组的方法") {
            var stus:[Student] = []
            var persons:[Person] = []
            beforeEach {
                let stu1 = Student(id: "1", name: "张三", age: 20)
                let stu2 = Student(id: "2", name: "李四", age: 22)
                let stu3 = Student(id: "3", name: "张二", age: 23)
                
                stus = [stu1,stu2,stu3]
                
                let person1 = Person()
                let person2 = Person()
                let person3 = Person()
                persons = [person1,person2,person3]
            }
            
            it("使用map过滤") {
                //使用compactMap 必须指定可选返回值类型：“-> Student?”
                let arr = stus.compactMap { sut -> Student? in
                    if sut.name.hasPrefix("张") {
                        return sut
                    }
                    return nil
                }
                print("匹配到\(arr.count)人，第一名：\(arr[0].name)")
            }
            
            it("使用断言过滤Struct结构体对象数组") {
                let pre = NSPredicate(format: "name contains [cd] '张二'")
                let arrr:NSArray = stus as NSArray
                let arr:[Student] = arrr.filtered(using: pre) as! [Student]
                print("匹配到\(arr.count)人，第一名：\(arr[0].name)")
            }
            
            fit("使用断言过滤类对象数组") {
                let pre = NSPredicate(format: "name contains [cd] '张二'")
                let arrr:NSArray = persons as NSArray
                let arr:[Person] = arrr.filtered(using: pre) as! [Person]
                print("匹配到\(arr.count)人，第一名：\(arr[0].name)")
            }
            
            it("使用filter过滤") {
                let arr = stus.filter { stu in
                    stu.age > 22
                }
                print("匹配到\(arr.count)人，第一名：\(arr[0].name)")
            }
            
            it("使用forEach筛选") {
                var arr:[Student] = []
                stus.forEach { sut in
                    if sut.name.hasPrefix("张") {
                        arr.append(sut)
                    }
                }
                print("匹配到\(arr.count)人，第一名：\(arr[0].name)")
            }
        }
    }
}
