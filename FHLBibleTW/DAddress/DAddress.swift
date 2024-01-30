//
//  DAddress.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/30.
//

import Foundation
open class DAddress {
    public var book = 0
    public var chap = 0
    public var verse = 0
    public var ver: String?
}
extension DAddress{
    public func toString(_ tp: BookNameLang)->String{
        if ( book < 1 || book > 66){
            return "\(book) \(chap):\(verse)"
        }
        
        let na = BibleBookNames.getBookName(book, tp)
        
        return "\(na) \(chap):\(verse)"
    }
}

/// 當要用 Set<DAddress> 時會用到
extension DAddress : Hashable {
    /// Type 'DAddress' does not conform to protocol 'Hashable'
    public func hash(into hasher: inout Hasher) {
        hasher.combine(book)
        hasher.combine(chap)
        hasher.combine(verse)
    }
}
/// 呼叫排序時 .sort （＜）　或　.sort（＞） r2.sort(by:＜)
extension DAddress : Equatable, Comparable {
    public static func < (lhs: DAddress, rhs: DAddress) -> Bool {
        if lhs.book < rhs.book { return true }
        if lhs.chap < rhs.chap { return true }
        if lhs.verse < rhs.verse { return true }
        return false
    }
    public static func == (lhs: DAddress, rhs: DAddress) -> Bool {
        return lhs.book == rhs.book && lhs.chap == rhs.chap && lhs.verse == rhs.verse
    }
}
extension VerseRange : Equatable {
    public static func == (lhs: VerseRange, rhs: VerseRange) -> Bool {
        if lhs.verses.count != rhs.verses.count { return false }
        
        let r1a = lhs.verses
        let r1b = rhs.verses
        
        for (a1,a2) in zip(r1a, r1b){
            if a1 != a2 {
                return false
            }
        }
        return true
    }
    
    
}
/// 直接呼叫 .distinct() 但沒有排序
extension Sequence where Iterator.Element: Hashable {
    func distinct() -> [Iterator.Element] {
        var r1: Set<Iterator.Element> = []
        return filter { r1.insert($0).inserted }
    }
}
extension Array where Element: Hashable{
    func ijnToSet()->Set<Element>{
        var r1: Set<Element> = Set()
        self.forEach({r1.insert($0)})
        return r1
    }
}
extension Set where Element: Hashable {
    mutating func ijnAppend(contentsOf: [Element]){
        contentsOf.forEach({self.insert($0)})
    }
}

extension DAddress {
    /// 產生整章 DAddress, 用 book, chap 參教
    func generateEntireThisChap()->[DAddress] {
        let r1 = BibleVerseCount.getVerseCount(self.book, self.chap)
        return (1...r1).lazy.map({DAddress(book: self.book, chap: self.chap, verse: $0, ver: self.ver)})
//        return ijnRange(1, r1).map({DAddress(book: self.book, chap: self.chap, verse: $0, ver: self.ver)})
    }
}

extension DAddress{
    func hashNumber()->Int { return self.book * 10000 + self.chap * 1000 + self.verse }
}

// sinq.orderBy，用於 mergeDiffVers 關鍵字 (閱讀時，合併兩個版本經文時)
// 若 sinq 要 orderBy [DAddress] 是不行的，只好將 [DAddress] 型成一個 class
class DAddresses : Comparable{
    static func < (lhs: DAddresses, rhs: DAddresses) -> Bool {
        let cnt = min(lhs.addresses.count,rhs.addresses.count)
        
        let r1 = (0..<cnt).lazy
        if sinq(r1).any({lhs.addresses[$0].hashNumber() < rhs.addresses[$0].hashNumber()}){
            return true
        }
        // 1:1-2 ... 1:1-4 [0][1] 前，還無法分勝負，若 lhs 少，就是 <
        return lhs.addresses.count < rhs.addresses.count
    }
    
    static func == (lhs: DAddresses, rhs: DAddresses) -> Bool {
        if lhs.addresses.count != rhs.addresses.count { return false }
        return sinq(lhs.addresses)
            .zip(rhs.addresses){($0,$1)}
            .all({$0.0.hashNumber() == $0.1.hashNumber()})
    }
    func hashNumber()->Int {
        return sinq(addresses).select({$0.hashNumber()}).reduce(0,+)
    }
    
    init(_ addrs:[DAddress]){
        self.addresses = addrs
    }
    var addresses: [DAddress]
}
