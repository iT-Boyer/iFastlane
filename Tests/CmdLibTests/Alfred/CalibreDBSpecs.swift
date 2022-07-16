//
//  AlfredSpecs.swift
//  CmdLibTests
//
//  Created by boyer on 2022/7/16.
//

import Foundation
import Quick
import Nimble
import GRDB
@testable import CmdLib

class CalibreDBSpecs: QuickSpec {
    override func spec() {
        
        var dbQueue:DatabaseQueue!
        beforeSuite {
            let dbPath = "/Users/boyer/rclone/Ali/Calibre/metadata.db"
            if let queue = try? DatabaseQueue(path: dbPath){
                dbQueue = queue
            }
        }
        
        describe("calibre查询") {
            
            beforeEach {}
            xit("统计书籍") {
                try dbQueue.read { db in
                    let request = CaliBook.all().select(count(Column("id")))
//                    let books = try CaliBook.fetchOne(db, request) // [nil]
                    let count = try Int.fetchOne(db, request)       // int
                    let bookCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM books")! // Int
                    print("目前收藏的书籍数目：\(bookCount)")
                }
            }
            
            it("搜索单列") {
                try dbQueue.read({ db in
                    let request = CaliBook.select(Column("title"))
                    let names = try String.fetchAll(db, request) // [String]
                    ///
                    let names2 = try String.fetchAll(db, sql: "SELECT title FROM books") // [String]
                    for name in names{
                        print("书籍名称：\(name)")
                    }
                })
            }
            
            xit("精确查询") {
                try dbQueue.read({ db in
                    let column = Column("title")
                    let request = CaliBook.filter(column == "三体三部曲")
                    let books = try CaliBook.fetchAll(db, request)
                    for book in books{
                        print("书籍路径：\(book.title ?? "") \n 位置：\(book.path ?? "")")
                    }
                })
            }
            
            it("模糊查询") {
                try dbQueue.read({ db in
                    let column = Column("title")
                    let request = CaliBook.all().filter(column.like("三体%"))
                    let books = try CaliBook.fetchAll(db, request)
                    for book in books{
                        print("书籍路径：\(book.title ?? "") \n 位置：\(book.path ?? "")")
                    }
                })
            }
            
            xit("") {
                let bookInfo: CaliBookInfo? = try dbQueue.read { db in
                    let request = CaliBook
                        .filter(key: "dd")
                        .including(required: CaliBook.author)
                    return try CaliBookInfo.fetchOne(db, request)
                }
                if let bookInfo = bookInfo {
                    print("\(bookInfo.book.title) was written by \(bookInfo.author.name)")
                }
            }
            
            
        }
    }
}
