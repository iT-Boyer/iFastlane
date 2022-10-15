//
//  File.swift
//  
//
//  Created by boyer on 2022/10/15.
//

import Foundation
import GRDB
import Quick
import Nimble
@testable import CmdLib

class SafairSpecs:QuickSpec
{
    override func spec(){
        var dbQueue: DatabaseQueue!
        var gdbQueue: DatabaseQueue!
        beforeSuite {
            //初始化数据库
            let dbPath = "/Users/boyer/Library/Safari/History.db"
            let googlePath = "/Users/boyer/Library/Application Support/Google/Chrome/Default/History"
            if let queue = try? DatabaseQueue(path: dbPath) {
                dbQueue = queue
            }
            
            do {
                gdbQueue = try DatabaseQueue(path: googlePath)
                print("错误信息：----------------")
            } catch {
                print("错误信息：\(error)")
            }
        }
        
        
        xdescribe("查询safari历史记录") {
            //            使用select查询语句
            it("使用select语句") {
                try dbQueue.inDatabase{ db in
                    let title = "nyan"
                    let url = ""
                    let query = """
SELECT history_items.id, title, url \
FROM history_items  \
INNER JOIN history_visits   \
ON history_visits.history_item = history_items.id   \
WHERE url LIKE '%\(url)%' OR title LIKE '%\(title)%' \
GROUP BY url    \
ORDER BY visit_time DESC
"""
                    let rows = try Row.fetchCursor(db, sql: query)
                    while let row = try rows.next() {
                        let title:String = row["title"]
                        let url:String = row["url"]
                        print("safari结果：\(title)")
                    }
                }
            }
        }
        
        fdescribe("查询chrome记录") {
            it("sql查询") {
                let url = "zerotier"
                let googleQuery = "select url, title from urls WHERE url LIKE '%\(url)%' OR title LIKE '%\(url)%'"
                try gdbQueue.read{db in
                    let rows = try Row.fetchAll(db, sql: googleQuery)
                    for row in rows {
                        let title:String = row["title"]
                        let url:String = row["url"]
                        print("google结果：\(title)")
                    }
                }
            }
        }
    }
}
