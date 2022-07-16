//
//  CalibreDB.swift
//  Alfred
//
//  Created by boyer on 2022/7/16.
//

import Foundation
import GRDB

//Query = "select books.title,books.path,authors.name,data.format,data.name from data,books,authors,books_authors_link where title like \"%" + query + "%\" and books.id=books_authors_link.book and authors.id=books_authors_link.author and data.book=books.id"
struct CaliBook:Codable,FetchableRecord, MutablePersistableRecord {
    var id:Int64?
    var title,path:String?
    static var databaseTableName = "books"
}

struct CaliAuthor:Codable, FetchableRecord, MutablePersistableRecord {
    var id:Int64?
    var name:String?
    static var databaseTableName = "authors"
}

struct CaliData:Codable,FetchableRecord, MutablePersistableRecord {
    var name:String?
    var book:String?
    static var databaseTableName = "data"
}

//: Define Associations

extension CaliAuthor { //一对多
    static let books = hasMany(CaliBook.self)
    var books: QueryInterfaceRequest<CaliBook> { request(for: CaliAuthor.books) }
}

extension CaliBook {
    static let author = belongsTo(CaliAuthor.self)
    var author: QueryInterfaceRequest<CaliAuthor> { request(for: CaliBook.author) }
}


struct CaliBookInfo: FetchableRecord, Codable {
    var book: CaliBook
    var author: CaliAuthor
}


public struct CalibreDB {
    
    //TODO:
    public static func filter(_ name:String, db dbFile:String) -> String? {
        //TODO: 链接sqlite3 数据库并查询
        // 1. Open a database connection
        do {
            let dbQueue = try DatabaseQueue(path: dbFile)
            let results: [CaliBookInfo]? = try dbQueue.read { db in
                let request = CaliBook
                    .filter(key: name)
                    .including(required: CaliBook.author)
                return try CaliBookInfo.fetchAll(db, request)
            }
            guard let books = results else { return nil }
            let items:[ResultModel] = books.compactMap{ info in
                let item = ResultModel(uid: "\(info.book.id)", type: "book", title: info.book.title, arg: info.book.path)
                return item
            }
            return AlfredJSON(items: items).toJson()
        } catch {
            return nil
        }
    }
}
