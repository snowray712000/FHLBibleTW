//
//  VerseRange.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/30.
//

import Foundation
open class VerseRange {
    init(_ verses:[DAddress]=[]){
        self.verses = verses
    }
    public var verses: [DAddress]
    public static func fromReferenceDescription(_ describe: String, book1BasedDefault: Int) -> VerseRange {
        
        abort()
    }
    /// fromReferenceDescription 的縮寫
    public static func fD(_ describe:String, book1BasedDefault: Int = 40) -> VerseRange {
        return VerseRange.fromReferenceDescription(describe, book1BasedDefault: book1BasedDefault)
    }
}
