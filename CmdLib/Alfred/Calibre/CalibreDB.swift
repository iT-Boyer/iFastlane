//
//  CalibreDB.swift
//  Alfred
//
//  Created by boyer on 2022/7/16.
//

import Foundation
import GRDB

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
    var format:String?
    static var databaseTableName = "data"
}

struct CaliLink:Codable,FetchableRecord, MutablePersistableRecord {
    var book:String?
    var author:String?
    static var databaseTableName = "books_authors_link"
}

//: Define Associations

extension CaliAuthor { //一对多
    static let link = hasMany(CaliLink.self)
    var link: QueryInterfaceRequest<CaliLink> { request(for: CaliAuthor.link) }
}

extension CaliBook {
    static let link = belongsTo(CaliLink.self)
    var link: QueryInterfaceRequest<CaliLink> { request(for: CaliBook.link) }
}


struct CaliBookInfo:Codable, FetchableRecord {
    var title,name,pyname,path,format:String?
}


public struct CalibreDB {
    public static func filter(_ name:String, db dbFile:String) -> String? {
        //TODO: 链接sqlite3 数据库并查询
        // 1. Open a database connection
        do {
            let dbQueue = try DatabaseQueue(path: dbFile + "/metadata.db")
            var books:[CaliBookInfo] = []
            try dbQueue.read { db in
                let query = "select books.title,books.path,authors.name,data.format,data.name as pyname from data,books,authors,books_authors_link where title like '%" + name + "%\' and books.id=books_authors_link.book and authors.id=books_authors_link.author and data.book=books.id"
                books = try CaliBookInfo.fetchAll(db, sql: query)   // Fetch database rows
            }
            let items = books.compactMap { bookInfo ->ResultModel? in
                let path = dbFile + "/" + bookInfo.path!
                let title = bookInfo.title
                let subtitle = (bookInfo.name ?? "") + (bookInfo.format ?? "")
                let arg = path + bookInfo.pyname! + "." + bookInfo.format!
                let valid = true
                let icon = path + "/cover.jpg"
                let item = ResultModel(uid: "",title: title, subtitle: subtitle,arg: arg, icon: Icon(path: icon), valid: valid)
                return item
            }
            return AlfredJSON(items: items).toJson()
        } catch {
            return nil
        }
    }
}
