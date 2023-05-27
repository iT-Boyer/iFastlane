//
//  File.swift
//  
//
//  Created by boyer on 2023/5/18.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let org2JSON = try Org2JSON(json)

import Foundation

// MARK: - Org2JSON
struct Org2JSONModel: Codable {
    let dataType: String
    let properties: FirstProperties
    let contents: [FirstContent]

    enum CodingKeys: String, CodingKey {
        case dataType = "$$data_type"
        case properties, contents
    }
    static func parsed<T:Decodable>(data:Data) -> T {
        do{
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        }catch{
            fatalError(#function+"解析失败：\(error)")
        }
    }
}

// MARK: - FirstProperties
struct FirstProperties: Codable {
    let title: [String]
    let filetags: [String]
    let author: [String]
    let creator: String
    let date, description: [String]
    let email, language: String
}

// MARK: - FirstContent
struct FirstContent: Codable {
    let dataType: DataType
    let type, ref: String
    let properties: SecondProperties
    let contents: [SecondContent]
    let drawer: OrgDrawer?

    enum CodingKeys: String, CodingKey {
        case dataType = "$$data_type"
        case type, ref, properties, contents, drawer
    }
}

// MARK: - SecondContent
struct SecondContent: Codable {
    let dataType: DataType
    let type, ref: String
    let properties: SecondProperties
    let contents: [ThirdContent]
    let drawer: OrgDrawer?

    enum CodingKeys: String, CodingKey {
        case dataType = "$$data_type"
        case type, ref, properties, contents, drawer
    }
}
struct ThirdContent: Codable {
    let dataType: DataType
    let type, ref: String
    let properties: SecondProperties
    let contents: [FourContent]
    let drawer: OrgDrawer?

    enum CodingKeys: String, CodingKey {
        case dataType = "$$data_type"
        case type, ref, properties, contents, drawer
    }
}
struct FourContent: Codable {
    let dataType: DataType
    let type, ref: String
    let properties: SecondProperties
    let contents: [String?]
    let drawer: OrgDrawer?

    enum CodingKeys: String, CodingKey {
        case dataType = "$$data_type"
        case type, ref, properties, contents, drawer
    }
}

// MARK: - SecondProperties
struct SecondProperties: Codable {
    let tagsAll: [String]?
    let rawValue: String?
    let preBlank: Int?
    let robustBegin, robustEnd: Int?
    let level: Int?
    let priority: Int?
    let tags: [String]?
    let todoKeyword, todoType: String?
    let postBlank: Int
    let footnoteSectionP, archivedp, commentedp: Bool?
    let postAffiliated: Int
    let title: [String]?
    let mode: String?
    let granularity: String?
    let key, value, type, path, format: String?
    let deadline: Deadline?
    let rawLink: String?
    let application, searchOption: String?
    let isInternal: Bool?
    let targetRef: String?
    let isInlineImage: Bool?
    
    enum CodingKeys: String, CodingKey {
        case tagsAll = "tags-all"
        case rawValue = "raw-value"
        case preBlank = "pre-blank"
        case robustBegin = "robust-begin"
        case robustEnd = "robust-end"
        case level, priority, tags
        case todoKeyword = "todo-keyword"
        case todoType = "todo-type"
        case postBlank = "post-blank"
        case footnoteSectionP = "footnote-section-p"
        case archivedp, commentedp
        case postAffiliated = "post-affiliated"
        case title, mode, granularity, key, value, deadline
        case type, path, format
        case rawLink = "raw-link"
        case application
        case searchOption = "search-option"
        case isInternal = "is-internal"
        case targetRef = "target-ref"
        case isInlineImage = "is-inline-image"
    }
}


enum DataType: String, Codable {
    case orgNode = "org-node"
}

// MARK: - FluffyDrawer
struct OrgDrawer: Codable {
    let remark: String?

    enum CodingKeys: String, CodingKey {
        case remark = "REMARK"
    }
}

// MARK: - Deadline
struct Deadline: Codable {
    let dataType, start, end, type: String
    let rawValue: String
    let repeater, warning: Repeater

    enum CodingKeys: String, CodingKey {
        case dataType = "$$data_type"
        case start, end, type
        case rawValue = "raw-value"
        case repeater, warning
    }
}


// MARK: - Repeater
struct Repeater: Codable {
    let type, unit, value: String?
}
