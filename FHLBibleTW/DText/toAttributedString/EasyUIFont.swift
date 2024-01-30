//
//  EasyUIFont.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/30.
//

import Foundation
import UIKit
/**
 UIFont 的初始化，對我來說，很不直覺。因此提供這個 class 。
 */
class EasyUIFont{
    private var _font: UIFont
    var font: UIFont {
        get {
            return _font
        }
        set {
            _font = newValue
        }
    }
    init(fontStyle: UIFont.TextStyle){
        _font = UIFont.preferredFont(forTextStyle: fontStyle)
    }
    init(fontRefernce: UIFont? = nil){
        if fontRefernce == nil{
            _font = UIFont.preferredFont(forTextStyle: .body)
        } else {
            _font = fontRefernce!
        }
    }
    static private var _fontSizes: [UIFont.TextStyle:CGFloat] = [
        .largeTitle: 34,
        .title1: 28,
        .title2: 22,
        .title3: 20
    ]
    
    /**
     台語、閔南語、客語。有些文字顯示為空白，因為 cell 的字型要使用這個。
     - 概念是初始化一個 Font 字型。接著還要使用 scaledFont 來縮放。
     - 字型大小，不要用數字，用 TextStyle。 .body 就是一般文字，標題大小，依大至小是 .largeTtile .title1 .title2 .title3。
     - 會重新產生 font。而非更改屬性。
     */
    func setNameForSupportHanText(fontStyle: UIFont.TextStyle = .body){
        let r1 = UIFont(name: "OpenHanBibleTC", size: Self._fontSizes[fontStyle] ?? 17.0)
        if r1 == nil {
            _font = UIFont.preferredFont(forTextStyle: fontStyle) // 原本方式
        } else {
            let r2 = UIFontMetrics(forTextStyle: fontStyle)
            _font = r2.scaledFont(for: r1!)
        }
    }
}
