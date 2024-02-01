//
//  uiabv.swift
//  FHLBible
//
//  Created by snowray712000@gmail.com on 2021/11/3.
// 請參考 qsb 實作新的, 這個也是參考那個作的
import Foundation

/// CBOL 字典, sd 的 d 應該是指 dictionary
/// k=03615&gb=0&N=1
func fhlSd(_ param: String,_ fn: @escaping FhlJson<DApiSd>.FnCallback) {
    fhlCore(param, "sd", fn)
}

class DApiSd : FhlJsonResult {
    enum CodingKeys: String,  CodingKey {
        case record
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        record = try container.decode([OneRecord].self, forKey: .record)
        record.forEach({$0.sn = removeSn000($0.sn!)})
        
        try super.init(from: decoder)
    }
    required init(_ status: String = "") {
        record = []
        super.init(status)
    }
    var record: [OneRecord]
    typealias OneRecord = DApiSdRecord
}
class DApiSdRecord : Decodable {
    /// "03615"
    var sn:String?
    var dic_text:String?
    var edic_text:String?
    /// 0: 新約 1:舊約
    var dic_type:Int?
    /// 原文
    var orig:String?
}

///
func removeSn000(_ a1:String?)-> String? {
    if a1 == nil { return nil }
    return ijnReplaceString(try! NSRegularExpression(pattern: #"^[0]*"#, options: []), a1!, "")
}
/// 從  Basic03 學到的
/// 基本: 簡化呼叫 replaceMatches 的參數
public func ijnReplaceString(_ reg: NSRegularExpression,_ str:String,_ strReplaced:String ) ->String {
    let r1 : NSMutableString = NSMutableString(string: str)
    let r2 = r1 as String
    reg.replaceMatches(in: r1, options: [], range: NSRange(r2.startIndex..<r2.endIndex, in: r2), withTemplate: strReplaced)
    return r1 as String
}
