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
        xdescribe("验证筛选对象数组的方法") {
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
        
        
        describe("验证swift属性用法") {
            
            it("验证计算属性的setter方法") {
                // 想要获取计算后的值，必须借助临时变量来辅助，例如：_number
                var _number = 0
                var number:Int{
                    set{
                        _number = newValue + 1
                    }
                    get{
                        return _number
                    }
                }
            }
            
            it("验证存储属性的观察器didSet方法") {
                //可以使用didSet方法优化JSONCoder解析可选类型字段，避免在程序中强制解包崩溃问题。
                var number :Int? = 0 {
                    didSet {
                        print(#function+":didSet")
                        number = number ?? 0
                        print("更新：\(number!)")
                    }
                }
                
                number = 3
                print("结果：\(number!)")
                
                number = nil
                print("结果：\(number!)")
            }
            
            fit("验证lazy属性执行时机,测试调用执行的次数") {
                // lazy 属性 仅执行一次
                lazy var test: String = {
                    print("加载lazy属性test")
                    return "TEST"
                }()
                
                _ = test
                _ = test
                _ = test
                print("lazy 属性 仅执行一次：\(test)")
            }
        }
    }
}
