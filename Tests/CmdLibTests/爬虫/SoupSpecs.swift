//
//  SoupSpecs.swift
//  Runner
//
//  Created by boyer on 2022/7/12.
//  
//
import Foundation
import Quick
import Nimble
import SwiftSoup

class SoupSpecs: QuickSpec {
    override class func spec() {
        
        describe("解析html标签") {
            
            it("解析html") {
                do {
                   let html = "<html><head><title>First parse</title></head>"
                       + "<body><p>Parsed HTML into a doc.</p></body></html>"
                   let doc: Document = try SwiftSoup.parse(html)
                   let note = try doc.text()
                   print("解析的内容：\(note)")
                } catch Exception.Error(let type, let message) {
                    print(message)
                } catch {
                    print("error")
                }
            }
            
            it("解析body") {
                let url = URL(string: "http://localhost:8686/")
                
                guard let myURL = url else {
                    print("Error: \(String(describing: url)) doesn't seem to be a valid URL")
                    return
                }
                let html = try! String(contentsOf: myURL, encoding: .utf8)
                
                do {
                    let doc: Document = try SwiftSoup.parseBodyFragment(html)
                    let headerTitle = try doc.title()
                    print("Header title: \(headerTitle)")
                } catch Exception.Error(let type, let message) {
                    print("Message: \(message)")
                } catch {
                    print("error")
                }
            }
        }
    }
}
