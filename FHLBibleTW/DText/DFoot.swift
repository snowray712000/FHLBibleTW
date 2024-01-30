//
//  DFoot.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/30.
//

import Foundation
/// 用於 DText 中的 Foot
/// { w: '【180】', foot: { book:1, chap: 4, version: 'cnet', id: 180 } } NET聖經中譯本
/// { w: '([4.1]「該隱」意思是「得」。)', foot: { text: '「該隱」意思是「得」。' } } 和合本2010
public class DFoot : NSObject {
    public init(text: String? = nil, book: Int? = nil, chap: Int? = nil, verse: Int? = nil, version: String? = nil, id: Int? = nil) {
        self.text = text
        self.book = book
        self.chap = chap
        self.verse = verse
        self.version = version
        self.id = id
    }
    public var text : String?
    public var book : Int?
    public var chap : Int?
    public var verse : Int?
    public var version : String?
    public var id : Int?
    
    /// 【180】 這種，用藍色
    public static func isBlueColor(_ ft: DFoot?) -> Bool {
        return ft != nil && ft!.id != nil
    }
    /// foot: { text: '「該隱」意思是「得」。' } } 這種，用紫色。
    public static func isPurpleColor(_ ft: DFoot?) -> Bool{
        return ft != nil && ft!.id == nil
    }
}
