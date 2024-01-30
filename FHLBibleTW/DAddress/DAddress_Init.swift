//
//  DAddress_Init.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/30.
//

import Foundation
extension DAddress {
    convenience init (_ book:Int = 0, _ chap: Int = 0 , _ verse: Int = 0,_ ver: String? = nil){
        self.init()
        
        self.book = book
        self.chap = chap
        self.verse = verse
        self.ver = ver
    }
    /// for SQLite
    convenience init(_ book:Int32,_ chap:Int32,_ verse:Int32) {
        self.init(Int(book),Int(chap),Int(verse))
    }
    convenience init(book: Int = 0, chap: Int = 0, verse: Int = 0, ver: String? = nil) {
        self.init()
        
        self.book = book
        self.chap = chap
        self.verse = verse
        self.ver = ver
    }
}
