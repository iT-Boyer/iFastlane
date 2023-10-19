//
//  Books.swift
//  CmdLib
//
//  Created by boyer on 2022/3/14.
//

import Foundation

let libraryXMLYN = """
<?xml version="1.0" encoding="UTF-8"?>
<library>
    <count>2</count>
    <books>
        <book id="123" author="Jack" gender="novel">
            <id>123</id>
            <author>Jack</author>
            <gender>novel</gender>
            <title>Cat in the Hat</title>
            <category main="Y"><value>Kids</value></category>
            <category main="N"><value>Wildlife</value></category>
        </book>
        <book id="456" author="Susan" gender="fantastic">
            <id>456</id>
            <author>Susan</author>
            <gender>fantastic</gender>
            <title>1984</title>
            <category main="Y"><value>Classics</value></category>
            <category main="N"><value>News</value></category>
        </book>
    </books>
</library>
""".data(using: .utf8)!

//图书馆
struct Library: Codable {
    let count: Int
    let books: [XmlBook]//XmlBooks

    enum CodingKeys: String, CodingKey {
        case count
        case books = "book"//"books"
    }
}

struct XmlBooks:Codable {
    let books:[XmlBook]
    enum CodingKeys: String, CodingKey {
        case books = "book"
    }
}

//图书
struct XmlBook: Codable {
    let id: Int
    let author: String
    let gender: String
    let title: String
    let categories: [Category]

//    enum CodingKeys: String, CodingKey {
//        case id
//        case author
//        case gender
//        case title
//        case categories = "category"
//    }

}

struct Category: Codable {
    let main: Bool
    let value: String

//    enum CodingKeys: String, CodingKey {
//        case main
//        case value
//    }
}
