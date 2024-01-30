//
//  DText_Clone.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/30.
//

import Foundation
extension DFoot {
    /// 用於 unit test 開發 BibleText2DTextTests
    /// 舉例來說，在 convert 過程，如果原本有 isFW2，然後被 split 之後，應該仍然保有 isFW2
    /// 也會被 DText 的 clone 呼叫
    public func clone() -> DFoot {
        let o = DFoot()
        o.book = book
        o.chap = chap
        o.verse = verse
        o.id = id
        o.text = text
        o.version = version
        return o
    }
}
extension DText {
    /// 用於 unit test 開發 BibleText2DTextTests
    /// 舉例來說，在 convert 過程，如果原本有 isFW2，然後被 split 之後，應該仍然保有 isFW2
    public func clone(_ isCloneChildren:Bool = true)->DText{
        let o = DText(w)
        o.sn = sn
        o.tp = tp
        o.tp2 = tp2
        o.isSnActived = isSnActived
        o.isCurly = isCurly
        o.isMerge = isMerge
        o.isParenthesesFW = isParenthesesFW
        o.isParenthesesHW = isParenthesesHW
        o.isParenthesesFW2 = isParenthesesFW2
        o.sobj = sobj
        o.isMap = isMap
        o.isPhoto = isPhoto
        o.isTitle1 = isTitle1
        //o.isRef = isRef
        o.refDescription = refDescription
        o.isBr = isBr
        o.isHr = isHr
        o.key = key
        o.keyIdx0based = keyIdx0based
        o.listTp = listTp
        o.listLevel = listLevel
        o.listIdx = listIdx
        o.isListStart = isListStart
        o.isListEnd = isListEnd
        o.isOrderStart = isOrderStart
        o.isOrderEnd = isOrderEnd
        o.idxOrder = idxOrder
        o.cssClass = cssClass
        o.isName = isName
        o.isBold = isBold
        o.isGODSay = isGODSay
        o.isOrigNotExist = isOrigNotExist
        o.cssColor = cssColor
        if (foot == nil){
            o.foot = nil
        } else {
            o.foot = foot!.clone()
        }
        if(children != nil){
            o.children = children!.map({a1 in a1.clone(isCloneChildren)})
        }
        o.tpContain = tpContain
        o.isGreek = isGreek
        o.isHebrew = isHebrew
        return o
    }
}
