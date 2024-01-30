//
//  DTextToAttributedString.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/30.
//

import Foundation
import UIKit

func to_attributedString(_ dtexts: [DText])->NSMutableAttributedString{
    let _isFontNameOpenHanBibleTC = true
    let _isVisibleSn = false
    let r2 = DTextDrawToAttributeString(_isVisibleSn,_isFontNameOpenHanBibleTC).mainConvert(dtexts)
    
    let re2 = NSMutableAttributedString()
    r2.forEach({re2.append($0)})
    return re2
}
