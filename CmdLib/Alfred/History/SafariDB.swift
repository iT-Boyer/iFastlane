//
//  File.swift
//  
//
//  Created by boyer on 2022/10/15.
//

import Foundation
import GRDB
import PathKit
/// 支持google和safari查询
/// 1. sql语句
/// 2. 处理数据为数组
/// 3. 整合到alfred中

public struct SafariDB {
    ///
    public static func search(_ keyword:String)->String? {
        let safariPath = "/Users/boyer/Library/Safari/History.db"
        let safariQuery = """
SELECT history_items.id, title, url \
FROM history_items  \
INNER JOIN history_visits   \
ON history_visits.history_item = history_items.id   \
WHERE url LIKE '%\(keyword)%' OR title LIKE '%\(keyword)%' \
GROUP BY url    \
ORDER BY visit_time DESC
"""
        let chrome = Path("/Users/boyer/Library/Application Support/Google/Chrome/Default/History")
        let googlePath = "/Users/boyer/tmp/History"
        let googleQuery = "select url, title from urls"
        //chrome history加锁，需要拷贝到临时目录
        do {
            let tmp = Path(googlePath)
            if (tmp.exists) {try tmp.delete()}
            try chrome.copy(tmp)
        } catch {
            let item = ResultModel(uid: "",title: "chrome拷贝失败")
            return AlfredJSON(items: [item]).toJson()
        }
        
        //开始查询
        let safair = dbQuery(safariPath, query: safariQuery)
        let google = dbQuery(googlePath, type: 1, query: googleQuery)
        let items = safair + google
        return AlfredJSON(items: items).toJson()
    }
    
    static func dbQuery(_ dbPath:String, type:Int = 0, query:String)->[ResultModel] {
        var items:[ResultModel] = []
        do {
            guard let dbQueue = try? DatabaseQueue(path: dbPath) else{
                return []
            }
            try dbQueue.read{ db in
                let rows = try Row.fetchAll(db, sql: query)
                
                items = rows.compactMap{ row ->ResultModel in
                    let title:String = row["title"]
                    let url:String = row["url"]
                    let icon = Icon(path: type == 1 ? "safari.png":"google.png")
                    let item = ResultModel(uid: "",title: title,subtitle: url,arg:url,icon: icon, valid: true)
                    return item
                }
            }
        } catch {}
        return items
    }
}
