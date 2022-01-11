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
            beforeEach {
                let stu1 = Student(id: "1", name: "张三", age: 20)
                let stu2 = Student(id: "2", name: "李四", age: 22)
                let stu3 = Student(id: "3", name: "张二", age: 23)
                
                stus = [stu1,stu2,stu3]
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
            
            it("使用断言过滤") {
                let pre = NSPredicate(format: "selected == 张二")
                let arr = stus.filtered(using: pre)
                print("匹配到\(arr.count)人，第一名：\(arr[0].name)")
            }
            
            it("使用filter过滤") {
                let arr = stus.filter { stu in
                    stu.age == 22
                }
            }
        }
    }
}
