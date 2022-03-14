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
        describe("解析tj3项目xml文件") {
            fit("获取项目名称") {
                let filePath = JHSources()+"project.xml"
                let xmlData = try! filePath.read()
                let project = try! XMLDecoder().decode(Project.self, from: xmlData)
//                let encodedXML = try! XMLEncoder().encode(project, withRootKey: "Project")
                print("解析taskjuggler项目：\(project.Name)")
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
