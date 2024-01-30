//
//  DText_others.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/30.
//

import Foundation

extension DText {
    /// 在 for 迴圈中, 常被用到
    /// 例如 w 是空, 或 isBr isHr, Sn 也無法再切割, #| 也不能再切割
    /// 通常 children 也不能切割啦 ... 因為它的 w 也通常是空的
    func isCantSplit()->Bool {
        if w == nil || w!.isEmpty { return true }
        
        if isBr == 1 || isHr == 1 { return true }
        
        if sn != nil { return true }
        
        if refDescription != nil { return true }
        
        if children != nil { return true }
        
        return false
    }
}

extension DText{
    func printDebug(){
        if children != nil {
            print ("\(tpContain ?? "(contain)") size=\(children!.count)")
            children!.forEach({$0.printDebug()})
        } else {
            if isBr == 1 { print ("(br)") }
            else if isHr == 1 { print ("(hr)")}
            else if sn != nil { print ("\(tp!)\(sn!)") }
            else if refDescription != nil { print ("\(refDescription!)") }
            else { print (w ?? "(empty)")}
        }
    }
}

/// TextView 點擊的原理，是判斷「第n個字元」
/// 然後從第n個字元，去找，是哪個 Dtext
/// 所以 children 的情況就比較複雜，像 ＜div＞ 的內容，不會有＜＞這字元產生
/// 但是同樣是 parent，身為 ()，他們的長度，左邊就算 1，右邊也算1個。
extension DText {
    /// 點擊，計算是哪個 DText 用的
    var cntChar: Int {
        if children != nil { return 0 }
        if w != nil { return w!.count }
        if isBr == 1 { return 2}
        return 0
    }
    /// 點擊，計算是哪個 DText 用的
    var cntCharContainFront: Int {
        if tpContain == "()" { return 1}
        if tpContain == "（）" { return 1}
        if tpContain == "qh" {return 1}// 「」
        return 0
    }
    /// 點擊，計算是哪個 DText 用的
    var cntCharContainBack: Int {
        if tpContain == "()" { return 1}
        if tpContain == "（）" { return 1}
        if tpContain == "qh" { return 1} // 「」
        return 0
    }
}
