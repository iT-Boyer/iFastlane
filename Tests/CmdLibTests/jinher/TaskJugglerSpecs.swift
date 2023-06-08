//
//  TaskJugglerSpecs.swift
//  Runner
//
//  Created by boyer on 2022/3/14.
//  
//
import Foundation
import Quick
import Nimble
import PathKit
import XMLCoder
@testable import CmdLib

class TaskJugglerSpecs: QuickSpec {
    override func spec() {
        xdescribe("解析tj3项目xml文件") {
            fit("获取项目名称") {
                let filePath = JHSources()+"project.xml"
                let xmlData = try! filePath.read()
                let project = try! XMLDecoder().decode(Project.self, from: xmlData)
//                let encodedXML = try! XMLEncoder().encode(project, withRootKey: "Project")
                let taskMain = project.Tasks?.items.first
                let tasks:[Task] = project.Tasks!.items
                let count = tasks.count
                print("""
                      项目名称：\(taskMain!.Name)
                      任务数：\(count)
                      """)
                let level1 = tasks.filter { task in
                    task.OutlineLevel == 1
                }
                level1.forEach { task in
                    //1.1
                    //1.1.1
                    //1.1.1.1
                    let wbs = task.WBS
                    //子任务
//                    let level2
                    for index in 0...4 {
                        
                    }
                    
                }
            }
       
            xit("图书馆") {
                let decoder = XMLDecoder()
                decoder.errorContextLength = 10
                let library = try decoder.decode(Library.self, from: libraryXMLYN)
                print("书本数：\(library.books.count)")
                print("图书馆数：\(library.count)")
                let book1 = library.books[0]
                let book2 = library.books[1]
                print("书本1名：\(book1.title)")
                print("书本2名：\(book2.title)")
            }
            
        }
    }
}
