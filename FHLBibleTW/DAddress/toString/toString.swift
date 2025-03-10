

import Foundation
/**
 - Notes:
    - 原本 to string 會依參數是否包含章與節來決定要顯示格式，但這樣是不對的。考慮一次閱讀的時候，是包含多了個 book 或 chap，但其中一節仍然只是 一節 而已，所以會誤判為 v3，但實際可能應該需要 `2:3` 甚至 `太2:3`。
    - 所以，應該先判定要什麼格式 (用本次所有的章節)，再產生。使用 test_tpToStringOfAddresses
 */
func to_string(_ verseRange: VerseRange,tp: TpToStringOfAddresses)->String {
    if tp == .none || verseRange.verses.count == 0{
        return ""
    }
    
    // 最常見的，只有一節，也最簡單的，所以先處理
    if verseRange.verses.count == 1 {
        let a1 = verseRange.verses[0]
        if tp == .verse {
            return "\(a1.verse)"
        }
        if tp == .chap {
            return "\(a1.chap):\(a1.verse)"
        }
        if tp == .book {
            let bk = BibleBookNames.getBookName(a1.book, .太)
            return "\(bk) \(a1.chap):\(a1.verse)"
        }
    }
    
    // 判斷 verse 是不是連續
    let isContinued = sinq ( verseRange.verses.enumerated() ).skip(1).all({verseRange.verses[$0.offset-1].verse + 1 == $0.element.verse} ) // 後面都會用到，所以提出來。
    
    if tp == .verse {
        if isContinued {
            // 3-4
            return "\(verseRange.verses[0].verse)-\(verseRange.verses.last!.verse)"
        } else {
            // 3,5,6
            return sinq( verseRange.verses ).select({"\($0.verse)"}).joined(separator: ",")
        }
    }
    
    if tp == .chap {
        let tp1 = test_tpToStringOfAddresses(verseRange.verses)
        if tp1 == .verse {
            if isContinued {
                // 3:1-4
                return "\(verseRange.verses[0].chap):\(verseRange.verses[0].verse)-\(verseRange.verses.last!.verse)"
            } else {
                // 3:1,3,4
                return "\(verseRange.verses[0].chap):" + sinq( verseRange.verses ).select({"\($0.verse)"}).joined(separator: ",")
            }
        }// 其它都用預設，預計不太常發生
    }
    
    if tp == .book {
        let tp1 = test_tpToStringOfAddresses(verseRange.verses)
        if tp1 == .verse {
            let bk = BibleBookNames.getBookName(verseRange.verses[0].book, .太)
            if isContinued {
                // 太 3:1-4
                return "\(bk) \(verseRange.verses[0].chap):\(verseRange.verses[0].verse)-\(verseRange.verses.last!.verse)"
            } else {
                // 太 3:1,3,4
                return "\(bk) \(verseRange.verses[0].chap):" + sinq( verseRange.verses ).select({"\($0.verse)"}).joined(separator: ",")
            }
        }
    }
    
    return VerseRangeToString().main(verseRange.verses)
}
enum TpToStringOfAddresses {
    case none
    case verse
    case chap
    case book
}
func test_tpToStringOfAddresses(_ addresses: [DAddress])->TpToStringOfAddresses {
    if addresses.count == 0 {
        return .none
    }
    if addresses.count == 1 {
        return .verse
    }
    let cntBook = sinq( addresses ).select({$0.book}).distinct().count
    let cntChap = sinq( addresses ).select({$0.chap}).distinct().count
    if cntBook == 1 && cntChap == 1 {
        return .verse
    }
    if cntBook == 1 {
        return .chap
    }
    return .book
}

/// 使用情境: VerseRange 常常要轉為 "創1" 或 "Ge1" 或 "创1" 等等
/// 使它相反的就是 VerseRange 的 fromReferenceDescription
/// 已完成 Tests
open class VerseRangeToString {
    public func main(_ addrs: [DAddress],_ tp:BookNameLang = .太)->String {
        let re = self.splitBookId(addrs);
        let re2 = re.map({self.splitContinueVerse($0)});
        let re3 = re2.map({self.splitTheSameChap($0)});
        let re4 = re3.map({self.getDescriptionEachBook($0, tp)}).joined(separator: ";")
        return re4;

    }
    private func getDescriptionEachBook(_ arg: [[[DAddress]]],_ lang: BookNameLang)-> String {
        let id = arg[0][0][0].book;
        let na = BibleBookNames.getBookName(id, lang);
        let des = arg.map({ (a1:[[DAddress]]) in
          // a1 可能是 1:23,25-27,30,32-42 (a1.length===4)
          // a1 可能是 1:23-25 (a1.length===1) (a1[0].length>1 && a1[0].first().chap == a1[0].last().chap)
          // a1 可能是 1:23-2:2 (a1.length===1) (a1[0].length>1 && a1[0].first().chap != a1[0].last().chap)
          // a1 可能是 1:23 (a1.length===1) (a1[0].length==1)
          // 第2種情況，可能縮成整章可能...約二 case (但qsb.php實際上, 約二, 會錯誤, 還是要傳入 約二1)
          if (a1.count > 1) {
            // a1: [[23],[25,26,27],[30],[32,33...41,42]]
            let chap = a1[0][0].chap;
            let r2 = a1.map({
                let a2 = $0
              let vr1 = a2[0];
              if (a2.count == 1) {
                return vr1.verse.description
//                return `${vr1.verse}`;
              } else {
                let vr2 = a2[a2.count - 1];
                return "\(vr1.verse)-\(vr2.verse)"
//                return `${vr1.verse}-${vr2.verse}`;
              }
            }).joined(separator: ",")
            return "\(chap):\(r2)" // case 1
//            return `${chap}:${r2}`; // case 1
          } else {
            let a2 = a1[0];
            let vr1 = a2[0];
            let chap = vr1.chap;
            if (a2.count > 1) {
              let vr2 = a2[a2.count - 1];
              if (vr1.chap != vr2.chap) {
                return "\(chap):\(vr1.verse)-\(vr2.chap):\(vr2.verse)" // case 3
//                return `${chap}:${vr1.verse}-${vr2.chap}:${vr2.verse}`; // case 3
              } else {
                if (vr1.verse == 1 && vr2.verse ==  BibleVerseCount.getVerseCount(id, chap) ) {
                    if ( BibleChapCount.getChapCount(id) == 1) {
                    return "1"; // 此書若只有一章, 連1都不用 (還是得加1,qsb才能接受)
                  }
                  return chap.description // case 2 special, 約二整章
                }
                return "\(chap):\(vr1.verse)-\(vr2.verse)" // case 2
                //return `${chap}:${vr1.verse}-${vr2.verse}`; // case 2
              }
            } else {
                return "\(chap):\(vr1.verse)" // case 4
              //return `${chap}:${vr1.verse}`; // case 4
            }
          }
        }).joined(separator: ";")
        let re4 = na + des;
        return re4;
      }
    private func splitTheSameChap(_ vrsOneBook: [[DAddress]])-> [[[DAddress]]] {
        var re3: [[[DAddress]]] = [];
        var sameChap:[[DAddress]] = [];
        var chap = -1;
        func fnPushSameChapToResult(){
          if (sameChap.count > 0) {
            re3.append(sameChap);
          }
          sameChap = [];
        };
        // tslint:disable-next-line: prefer-for-of
        for i in 0..<vrsOneBook.count {
          let vrsOneContinue = vrsOneBook[i];
          let vr1 = vrsOneContinue[0];
          if (vrsOneContinue.count > 1) { // 有連續的
            let vr2 = vrsOneContinue[vrsOneContinue.count - 1];
            if (vr1.chap != vr2.chap) {
              // 是 2:3-3:1 不是 2:3-5 這種
              fnPushSameChapToResult();
              sameChap.append(vrsOneContinue);
              fnPushSameChapToResult();
              // 下一個不論是什麼, 都重新開始累計
              chap = -1;
            } else {
              // 是 2:3-5 這種, 不是 2:3-3:1 這種
              if (chap == vr1.chap) {
                sameChap.append(vrsOneContinue);
              } else {
                fnPushSameChapToResult();
                // 下一個
                sameChap.append(vrsOneContinue);
                chap = vr1.chap;
              }
            }
          } else {
            if (vrsOneContinue[0].chap != chap) {
              fnPushSameChapToResult();
              // 下一個
              sameChap.append(vrsOneContinue);
              chap = vr1.chap;
            } else {
              sameChap.append(vrsOneContinue);
            }
          }
        }
        if (sameChap.count > 0) {
          re3.append(sameChap);
        }
        return re3;
      }
    private func splitContinueVerse(_ vrsOneBook: [DAddress])-> [[DAddress]] {
        var re2:[[DAddress]] = [];
        var re1:[DAddress] = [];
        for i in 0..<vrsOneBook.count {
          if (i != 0 && self.isContinueVerse(vrsOneBook[i - 1], vrsOneBook[i])) {
            re1.append(vrsOneBook[i]);
          } else {
            if (re1.count != 0) {
              re2.append(re1);
            }
            re1 = [];
            re1.append(vrsOneBook[i]);
          }
        }
        if (re1.count != 0) {
          re2.append(re1);
        }
        return re2;
      }
    private func isContinueVerse(_ vr1: DAddress,_ vr2: DAddress)->Bool {
        if (vr1.chap == vr2.chap) {
          if (vr1.verse + 1 == vr2.verse) {
            return true;
          } else {
            return false;
          }
        } else {
          if (vr1.chap + 1 == vr2.chap && vr2.verse == 1) {
            if ( BibleVerseCount.getVerseCount(vr1.book, vr1.chap
            ) == vr1.verse) {
              return true;
            } else {
              return false;
            }
          } else {
            return false;
          }
        }
      }
    private func splitBookId(_ verses: [DAddress])-> [[DAddress]] {
        var re: [[DAddress]] = [];
        var id: Int = -999 ;
        var r1: [DAddress] = [];
        for it1 in verses {
          if (id == it1.book) {
            r1.append (it1);
          } else {
            if (r1.count != 0) {
                re.append(r1)
            }
            r1 = [];
            id = it1.book;
            r1.append(it1);
          }
        }
        if (r1.count != 0) {
          re.append(r1);
        }
        return re;
      }
}
