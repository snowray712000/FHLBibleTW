//
//  DText_Init.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/30.
//

import Foundation
extension DText {
    public convenience init(_ w:Substring){
        self.init()
        self.w = String(w)
    }
    public convenience init(_ w: String){ self.init() ; self.w = w }
    /// 小括號 半型
    public convenience init(_ w: String, isParenthesesHW: Bool, isInTitle: Bool = false) {
        self.init()
        self.w = w
        self.isParenthesesHW = isParenthesesHW ? 1 : 0
        if isInTitle { self.isTitle1 = 1 }
    }
    /// sn: 11 tp: G tp2: WG or WAG or WTG
    public convenience init(_ w: String, sn: String,
                            tp: String, tp2: String ) {
        self.init()
        self.w = w
        self.sn = sn
        self.tp = tp
        self.tp2 = tp2
    }
    /// sn: 11 tp: G tp2: WG or WAG or WTG  花括號，大括號   1 | 0;
    public convenience init(_ w: String, sn: String, tp: String, tp2: String, isCurly: Bool ) {
        self.init()
        self.w = w
        self.sn = sn
        self.tp = tp
        self.tp2 = tp2
        if isCurly { self.isCurly =  1 }
    }
    /// sn: 11 tp: G tp2: WG or WAG or WTG ，並且 Sn 是否Active ;
    public convenience init(_ w: String, sn: String, tp: String, tp2: String, isActived: Bool ) {
        self.init()
        self.w = w
        self.sn = sn
        self.tp = tp
        self.tp2 = tp2
        if isActived { self.isSnActived = 1 }
    }
    /// 新譯本 詩3:1，同時會使 FW 也變為 1
    public convenience init(_ w: String, isParenthesesFW2: Bool ) {
        self.init()
        self.w = w
        if isParenthesesFW2 {
            self.isParenthesesFW = 1
            self.isParenthesesFW2 = 1
        }
    }
    /// 新譯本 詩3:1
    public convenience init(_ w: String, isParenthesesFW: Bool ) {
        self.init()
        self.w = w
        if isParenthesesFW {
            self.isParenthesesFW = 1
        }
    }
    /// 新譯本 詩3:1
    public convenience init(_ w: String, isTitle1: Bool ) {
        self.init()
        self.w = w
        if isTitle1 {
            self.isTitle1 = 1
        }
    }
    /// 搜尋結果
    public convenience init(
        _ w: String,
        keyword:String,key0basedIdx: Int) {
        
        self.init()
        self.w = w
        
        self.key = keyword
        self.keyIdx0based = key0basedIdx
    }
    /// 交互參照
    public convenience init(
        _ w: String,
        refDescription: String,
        isInTitle: Bool) {
        
        self.init()
        self.w = w
        
        //self.isRef = 1
        self.refDescription = refDescription
        if isInTitle { self.isTitle1 = 1}
    }
    public convenience init(
        isNewLine: Bool){
        
        self.init()
        self.w = nil
        
        if isNewLine { self.isBr = 1 }
    }
    public convenience init(
        isHr: Bool){
        
        self.init()
        self.w = nil
        
        if isHr { self.isHr = 1 }
    }
    /// 私名號，地名。
    public convenience init(
        _ str: String?,
        isName: Bool,
        isInTitle: Bool = false,
        isInHW: Bool = false,
        isInFW: Bool = false,
        isInFW2: Bool = false){
        
        self.init(str,isInTitle:isInTitle,isInHW:isInHW,isInFW:isInFW,isInFW2:isInFW2)
        
        self.isName = 1
//        if isInTitle { self.isTitle1 = 1 }
//        if isInHW { self.isParenthesesHW = 1 }
//        if isInFW { self.isParenthesesFW = 1 }
//        if isInFW2 { self.isParenthesesFW2 = 1 }
    }
    /// 虛點點
    public convenience init(
        _ str: String?,
        isOrigNotExist: Bool,
        isInTitle: Bool = false,
        isInHW: Bool = false,
        isInFW: Bool = false,
        isInFW2: Bool = false){
        
        self.init( str, isInTitle:isInTitle, isInHW:isInHW, isInFW:isInFW, isInFW2:isInFW2)
        
        self.isOrigNotExist = 1
//        if isInTitle { self.isTitle1 = 1 }
//        if isInHW { self.isParenthesesHW = 1 }
//        if isInFW { self.isParenthesesFW = 1 }
//        if isInFW2 { self.isParenthesesFW2 = 1 }
    }
    public convenience init(
        _ str: String?,
        isInTitle: Bool = false,
        isInHW: Bool = false,
        isInFW: Bool = false,
        isInFW2: Bool = false){
        
        self.init()
        self.w = str
        
        if isInTitle { self.isTitle1 = 1 }
        if isInHW { self.isParenthesesHW = 1 }
        if isInFW { self.isParenthesesFW = 1 }
        if isInFW2 { self.isParenthesesFW2 = 1 }
    }
    public convenience init(
        _ str: String?,
        foot: DFoot,
        isInTitle: Bool = false,
        isInHW: Bool = false,
        isInFW: Bool = false,
        isInFW2: Bool = false){
        
        self.init( str, isInTitle:isInTitle, isInHW:isInHW, isInFW:isInFW, isInFW2:isInFW2)
        
        self.foot = foot
    }
    public convenience init(
        _ str: String?,
        isGodSay: Bool,
        isInTitle: Bool = false,
        isInHW: Bool = false,
        isInFW: Bool = false,
        isInFW2: Bool = false){
        
        self.init( str, isInTitle:isInTitle, isInHW:isInHW, isInFW:isInFW, isInFW2:isInFW2)
        
        self.isGODSay = 1
    }
    public convenience init(
        tpContain: String?,
        children: [DText],
        isInTitle: Bool = false,
        isInHW: Bool = false,
        isInFW: Bool = false,
        isInFW2: Bool = false){
        
        self.init( nil, isInTitle:isInTitle, isInHW:isInHW, isInFW:isInFW, isInFW2:isInFW2)
        
        self.children = children
        self.tpContain = tpContain
    }
}
