//
//  EasyStringAttributes.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/30.
//

import Foundation
import UIKit
/**
 提供給 NSMutableAttributedString 的參數 attributes 的 Value 是 Any ，所以比較不易使用，也不直覺。
 - 特別不直覺的是 font 設定， font size 與 font 又綁在一起。
 - font 在希伯來文，希臘文，閩南語、客語，都會要特殊處理，否則會出現空白字。
 - 以 getter setter 來實作，未來可能會用到 copy from 某個屬性，所以就這樣設計吧。
 - 若傳 nil 為值，表示是移除某個屬性。
 */
class EasyStringAttributes {
    var resultAttributes: [NSAttributedString.Key: Any] = [:]
    init () {
        // 不能不設 .font 會爆掉，所以預設給 .body
        resultAttributes[.font] = EasyUIFont().font
    }
    /**
     字型 (支援 閩南語、客語) 由此決定，字大小。
     - font 一定會有，所以 getter 不使用 optional。有預設值，程式才不會爆掉。
     - 因為 UIFont 本身難以使用，所以才使用 EasyUIFont。
     */
    var fontEasy: EasyUIFont {
        set {
            resultAttributes[.font] = newValue.font
        }
        get {
            let font = resultAttributes[.font] as! UIFont
            return EasyUIFont(fontRefernce: font)
        }
    }
    /**
     字體顏色。
     - .label 是一個不錯的預設值。
     */
    var fontColor: UIColor? {
        set {
            if newValue == nil{
                resultAttributes.removeValue(forKey: .foregroundColor)
            } else {
                resultAttributes[.foregroundColor] = newValue!
            }
        }
        get {
            
            return resultAttributes[.foregroundColor] as? UIColor
        }
    }
    /**
     底線、虛點點
     - 底線 .single
     - 虛點點 .patternDot
     */
    var underLineOrDot: NSUnderlineStyle?{
        get{
            return resultAttributes[.underlineStyle] as? NSUnderlineStyle
        }
        set{
            // 底線 or 虛點點 嗎?
            if newValue == nil {
                resultAttributes.removeValue(forKey: .underlineStyle)
            } else {
                resultAttributes[.underlineStyle] = newValue!.rawValue
            }
        }
    }
    /// 斜體嗎?。斜體其實是設定 obliqueness 屬性，0.25 是有點歪，0 是沒有歪。
    var isItaly: Bool? {
        get {
            let r1 = resultAttributes[.obliqueness]
            return r1 != nil
        }
        set {
            if newValue == nil || newValue! == false {
                resultAttributes.removeValue(forKey: .obliqueness)
            } else {
                resultAttributes[.obliqueness] = 0.25 // 0 是沒有
            }
        }
    }
    var link: String? {
        get {
            return resultAttributes[.link] as? String
        }
        set {
            if newValue == nil {
                resultAttributes.removeValue(forKey: .link)
            } else {
                resultAttributes[.link] = newValue!
            }
        }
    }
}
