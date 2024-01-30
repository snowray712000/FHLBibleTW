//
//  DText_IsTheSame.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/30.
//

import Foundation
/// 用於 unit test 開發 BibleText2DTextTests
public func isTheSameDtext(_ a1:DText,_ a2:DText) -> Bool {
    if (a1.w != a2.w ) { return false }
    if (a1.sn != a2.sn ) { return false }
    if (a1.tp != a2.tp ) { return false }
    if (a1.tp2 != a2.tp2 ) { return false }
    if (a1.refDescription != a2.refDescription ) { return false }
    if (a1.isRef != a2.isRef ) { return false }
    
    if (a1.isParenthesesFW != a2.isParenthesesFW ) { return false }
    if (a1.isParenthesesHW != a2.isParenthesesHW ) { return false }
    if (a1.isParenthesesFW2 != a2.isParenthesesFW2) { return false }
    if (a1.isCurly != a2.isCurly ) { return false }

    if (a1.isBr != a2.isBr ) { return false }
    if (a1.isHr != a2.isHr ) { return false }
    if (a1.isMap != a2.isMap ) { return false }
    if (a1.isName != a2.isName ) { return false }
    if (a1.isBold != a2.isBold ) { return false }
    if (a1.isMerge != a2.isMerge ) { return false }
    if (a1.isPhoto != a2.isPhoto ) { return false }
    if (a1.isTitle1 != a2.isTitle1 ) { return false }
    if (a1.isGODSay != a2.isGODSay ) { return false }
    if (a1.isSnActived != a2.isSnActived ) { return false }

    if (a1.children != nil && a2.children != nil){
        if ( isTheSameDTexts(a1.children!, a2.children!) == false ){
            return false
        }
    } else if (a1.children == nil && a2.children == nil){
    }
    else { return false }
    
    if (a1.tpContain != a2.tpContain ) { return false }
    return true
}
/// 用於 unit test 開發 BibleText2DTextTests
public func isTheSameDTexts(_ a1:[DText],_ a2:[DText]) -> Bool {
    if a1.count != a2.count {
        return false
    }
    
    for i in 0..<a1.count {
        if (isTheSameDtext(a1[i], a2[i])==false) {
            return false
        }
    }
    return true
}
