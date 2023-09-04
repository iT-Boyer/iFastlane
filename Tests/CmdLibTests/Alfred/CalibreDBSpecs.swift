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
    override class func spec() {
        
        var dbQueue:DatabaseQueue!
        beforeSuite {
            let dbPath = "/Users/boyer/rclone/Ali/Calibre/metadata.db"
            if let queue = try? DatabaseQueue(path: dbPath){
                dbQueue = queue
            }
        }
        describe("基础Sql语句查询") {
            /**
             参考：
             AssociationPrefetchingSQLTests.swift
             AssociationsBasics.md
             */
            xit("Row:多表查询sql") {
                try dbQueue.inDatabase { db in
                    print("> KISS: Fetch from SQL")
                    let title = "三体"
                    let query = "select books.title,books.path,authors.name,data.format,data.name as pyname from data,books,authors,books_authors_link where title like '%" + title + "%\' and books.id=books_authors_link.book and authors.id=books_authors_link.author and data.book=books.id"
                    let rows = try Row.fetchCursor(db, sql: query)   // Fetch database rows
                    while let row = try rows.next() {                           // Decode database rows
                        let title: String = row["title"]
                        let path: Bool = row["path"]
                        print("Fetched", title, path)
                    }
                }
            }
            it("多表查询sql") {
                try dbQueue.inDatabase { db in
                    print("> KISS: Fetch from SQL")
                    let title = "三体"
                    let query = "select books.title,books.path,authors.name,data.format,data.name as pyname from data,books,authors,books_authors_link where title like '%" + title + "%\' and books.id=books_authors_link.book and authors.id=books_authors_link.author and data.book=books.id"
                    let books = try CaliBookInfo.fetchAll(db, sql: query)   // Fetch database rows
                    let items = books.compactMap { bookInfo ->ResultModel? in
                        let title = bookInfo.title
                        let subtitle = bookInfo.name
                        let arg = bookInfo.path! + bookInfo.pyname! + "." + bookInfo.format!
                        let valid = true
                        let icon = bookInfo.path! + "/cover.jpg"
                        let item = ResultModel(uid: "",title: title, subtitle: subtitle,arg: arg, icon: Icon(path: icon), valid: valid)
                        return item
                    }
                    if let json = AlfredJSON(items: items).toJson(){
                        print(json)
                    }
                }
            }
        }
        
        describe("GRDB：select相关查询") {
            xit("统计书籍") {
                try dbQueue.read { db in
                    let request = CaliBook.all().select(count(Column("id")))
//                    let books = try CaliBook.fetchOne(db, request) // [nil]
                    let count = try Int.fetchOne(db, request)       // int
                    let bookCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM books")! // Int
                    print("目前收藏的书籍数目：\(bookCount)")
                }
            }
            
            xit("搜索单列，返回列表值数组") {
                try dbQueue.read({ db in
                    // 返回字符串数组：等价： let names = String.fetchAll(db, sql: "SELECT title FROM books")
                    let request = CaliBook.select(Column("title"))
                    let names = try String.fetchAll(db, request) // [String]
                    for name in names{
                        print("书籍名称：\(name)")
                    }
                })
            }
            
            /**
             SELECT id, email FROM player
             两种语法：
             1. let request = Player.select([Column("id"), Column("email")])
             2.
             var request = Player.all()
             request = request.select { db in [Column("id"), Column("email")] }
             */
            xit("搜索指定列") {
                try dbQueue.read{ db in
                    var request = CaliBook.all()
                    request = request.select { db in [Column("id"), Column("title")] }
                    let rows = try Row.fetchAll(db, request) // [String]
                    for row in rows{
                        let title: String = row["title"]
                        let path: Bool = row["path"]
                        print("Fetched", title, path)
                    }
                }
            }
        }
        
        describe("GRDB：where查询") {
            beforeEach {}
            
            xit("精确查询") {
                // select * from books where title == '三体三部曲'
                try dbQueue.read({ db in
                    let request = CaliBook.filter(Column("title") == "三体三部曲")
                    let books = try CaliBook.fetchAll(db, request)
                    for book in books{
                        print("书籍路径：\(book.title ?? "") \n 位置：\(book.path ?? "")")
                    }
                })
            }
            
            xit("模糊查询") {
                // select * from books where title like '%三体%'
                try dbQueue.read({ db in
                    let column = Column("title")
                    let request = CaliBook.all().filter(column.like("三体%"))
                    let books = try CaliBook.fetchAll(db, request)
                    for book in books{
                        print("书籍路径：\(book.title ?? "") \n 位置：\(book.path ?? "")")
                    }
                })
            }
        }
    }
}
