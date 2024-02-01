//
//  Date_fromString.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/2/1.
//

import Foundation
extension Date {
    // yyyy/MM/dd HH:mm:ss 這是 uiabv.php 的字串型態
    public static func ijnFromStr(_ str: String?) -> Date? {
        guard let str = str else { return nil }
        if str.count == 0 { return nil }
        
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return df.date(from: str)
    }
}
