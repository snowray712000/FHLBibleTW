//
//  qsbToDTexts.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/2/1.
//

import Foundation
import UIKit
/// 為了 BibleReadDataGetter 開發 (實際用在 BibleGetterViaFhlApiQsb)
public protocol IQsbRecords2DOneLines {
    /// - Parameters:
    ///   - records: fhlQsb 結果
    ///   - ver: "unv" 等字串 (因為中文，有可能簡體繁體，所以直接用英文)
    func cvt(_ records: [DApiQsbRecord],_ ver: String) -> [DOneLine]
}

class QsbRecords2DOneLines01 : IQsbRecords2DOneLines {
    func cvt(_ records: [DApiQsbRecord], _ ver: String) -> [DOneLine] {
        let re1 = step1(records, ver) /// 此處完成後，還是所有 {w.} 還沒有把 sn foot 等分離
        let re2 = step2(re1,ver)
        
        return re2
    }
    private func step1(_ records:[DApiQsbRecord],_ ver:String) -> [DOneLine]{
        func c1(_ a1: DApiQsbRecord)->DOneLine{
            let re = DOneLine()
            re.ver = ver
            let bk = BibleBookNameToId().main1based(.Matt, a1.engs)
            
            // 為了 cnet 版本，注腳而改的
            re.address2 = DAddress(bk, a1.chap, a1.sec)
            // re.addresses = "\(a1.engs)\(a1.chap):\(a1.sec)" // 為了提昇效率, 改成2版本
            re.children = [DText(a1.bible_text)]
            return re
        }
        
        return records.map({c1($0)})
    }
    private func step2(_ dtexts: [DOneLine],_ ver:String)->[DOneLine]{
        /// ver: "unv"
        /// 將 dtext 作處理 (從純文字，切割為特殊)
        return BibleText2DText().main(dtexts,ver)
    }
}
