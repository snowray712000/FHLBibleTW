//
//  DText.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/30.
//

import Foundation
/// 參考 NUIRWD https://github.com/snowray712000/NUIRWD/blob/bible-text-show/src/app/bible-text-convertor/AddBase.ts
public class DText : NSObject {
    public var w : String?
    /// 不含 H 或 G, 且數字若有零會去頭
    public var sn : String?
    /// H, Hebrew G, Greek //'H' | 'G';
    public var tp : String?
    /// T, time 時態  'WG' | 'WTG' | 'WAG' | 'WTH' | 'WH';
    public var tp2 : String?
    /// 是否等於目前 active sn 0|1
    public var isSnActived: Int?
    /// 花括號，大括號   1 | 0;
    public var isCurly: Int?
    /// 此節是 'a', 且無法與上節合併時, 會顯示 '併入上節' 並且加上 isMerge=1, 若已與上節合併, 會修正上節的 verses, 並將此節 remove 掉 1
    public var isMerge: Int?
    /// 和合本 小括號(全型 FullWidth), 用在注解(或譯....), 或是標題時(大衛的詩)  1
    public var isParenthesesFW: Int?
    /// 和合本 小括號(半型 HalfWidth), cbol時 1
    public var isParenthesesHW: Int?

    /// 和合本 小括號(全型), 連續2層括號, 內層 新譯本 詩3:1 1
    public var isParenthesesFW2: Int?
    /// sobj 的資料, 地圖與相片
    public var sobj: Any?
    public var isMap: Bool?
    public var isPhoto: Bool?
      
    /// 新譯本是 h3；和合本2010 h2 1
    public var isTitle1: Int?
    /// 交互參照 1
    //public var isRef: Int?
    public var isRef: Int? { refDescription != nil ? 1 : nil }
    /// 交互參照內容 */
    public var refDescription: String?
    /// 換行, 新譯本 h3 與 非h3 交接觸 1*/
    public var isBr: Int?
    /// hr/, 原文字典，不同本用這個隔開. 1*/
    public var isHr: Int?
    /// 搜尋時，找到的keyword，例如「摩西」 */
    public var key: String?
    /// 搜尋時，找到的keyword，例如「摩西 亞倫」, 摩西, 0, 這可能是上色要用到 */
    public var keyIdx0based: Int?
    public var listTp: ListTp?;
    /// 1是第一層, 0就是純文字了 */
    public var listLevel: Int?
    /// 當時分析的層數 */
    public var listIdx: [Int]?
    /// 若出現這個, html 就要加 <li>  0 | 1; */
    public var isListStart: Int?
    /// 若出現這個, html 就要加 </li>  0 | 1; */
    public var isListEnd: Int?
    /// 若出現這個, html 就要加 </ol> 或 </ul>  0 | 1; */
    public var isOrderStart: Int?
    /// 若出現這個, html 就要加 </ol> 或 </ul>  0 | 1; */
    public var isOrderEnd: Int?

    /// idxOrder, 有這個 html 繪圖可以更加漂亮, 交錯深度之類的 */
    public var idxOrder: Int?

    /// twcb orig dict 出現的, 它原本就是 html 格式, 若巢狀, 愈前面的 class 愈裡層 */
    public var cssClass: String?

    /**
     rt.php?engs=Gen&chap=4&version=cnet&id=182 真的缺一參數不可,試過只有id不行
     和合本 2010 版, 是只有 text ([4.1]「該隱」意思是「得」。)
     csb: 中文標準譯本 cnet: NET聖經中譯本
     */
    public var foot: DFoot?
      // 私名號。底線  0 | 1;
    public var isName: Int?
      // 粗體。和合本2010、<b></b>  0 | 1;
    public var isBold: Int?
      // 紅字。耶穌說的話，會被標紅色。有些版本這麼作。 0 | 1;
    public var isGODSay: Int?
      // 虛點點。和合本，原文不存在，為了句子通順加上的翻譯。 0 | 1;
    public var isOrigNotExist: Int?
      // rgb(195,39,43) 中文標準譯本 csb ， 紅字，是用 span style css color rgb(x,x,x)
    public var cssColor: String?
    
    public enum ListTp : String{
        case ol = "ol"
        case ul = "ul"
    }
    /// title, FW, order list, 都可能用, 與 tpContain 使用
    public var children : [DText]?
    /// 配合 children 的，容器當初的 tp 是什麼，是 h1 還是 h2 還是 h3，又或著是 ) 還是 全型 )，又或著是 Fi 之類的
    public var tpContain : String?
    /// 點擊 Sn 後，可能是用 彙編，可能是用 字典功能
    public var snAction: SnAction?
    public enum SnAction : String {
        case list = "list"
        case parsing = "parsing"
        case cbol = "cbol"
        case cbole = "cbole"
        case twcb = "twcb"
        case dict = "dict"
    }
    /// 顯示上可用，若是 hebrew 可用較大的字型大小，之類的
    /// try! NSRegularExpression(pattern: "[\u{0590}-\u{05fe}]+", options: [])
    public var isHebrew: Int?
    /// try! NSRegularExpression(pattern: "[\u{0370}-\u{03ff}\u1f00-\u1fff]+", options: [])
    public var isGreek: Int?
}
