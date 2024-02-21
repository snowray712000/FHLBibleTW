//
//  VCRead.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/7.
//

import Foundation
import UIKit
import FHLCommon

enum TpToStringOfAddresses {
    case none
    case book
    case chap
    case verse
}
func test_tpToStringOfAddresses(_ r1:[DAddress])->TpToStringOfAddresses {
    if r1.count == 0 { return .none }
    if sinq( r1 ).select({$0.book}).distinct({$0}).count() > 1 {
        return .book
    }
    if sinq( r1 ).select({$0.chap}).distinct({$0}).count() > 1 {
        return .chap
    }
    return .verse
}
func to_string( addrs:[DAddress],tp: TpToStringOfAddresses)->NSMutableAttributedString {
    if tp == .none { return NSAttributedString() as! NSMutableAttributedString}
    
    var re = "\(addrs[0].verse)"
    if tp == .verse {
        if addrs.count > 1 {
            re = "\(addrs[0].verse)-\(addrs[addrs.count-1].verse)"
        }
    } else if tp == .chap {
        if addrs.count == 1 {
            let a1 = addrs[0]
            re = "\(a1.chap):\(a1.verse)"
        } else {
            let a1 = addrs[0]
            let a2 = addrs[addrs.count-1]
            re = "\(a1.chap):\(a1.verse)-\(a2.verse)"
        }
    } else {
        if addrs.count == 1 {
            let a1 = addrs[0]
            let bookna = get_booknames_via_tp(tp: ManagerLangSet.s.curTpBookNameLang)[a1.book-1]
            re = "\(bookna)\(a1.chap):\(a1.verse)"
        } else {
            re = VerseRangeToString().main(addrs)
        }
    }
        
    return DText_To_AttributedString(dtexts: [DText(re)], isSnVisible: false, isTCSupport: true)
}
public class VCRead: UITableViewController {
    typealias VerseRange = [DAddress]
    typealias DData = [(VerseRange,[DText])]
    var data$: Observable<DData> = Observable([])
    
    /**
     當 data$ 變更時，會更新一次。在計算某 row cell 時，會用到。(雖然可以每次都計算，但應該是 data 算一次時就夠了)
     */
    var tpAddresses: TpToStringOfAddresses = .none
    
    var _addrsCur: VerseRange = [DAddress(45,1,1)]
    var _addrsCurChanged$: Observable<Int> = Observable(0)
    
    @IBOutlet weak var btnTitle: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        btnTitle.setTitle("羅13", for: .normal)
        
        data$.afterChange += { [weak self] (_, new) in
            guard let self = self else { return }
            
            // update tpAddresses
            var r1:[DAddress] = self._addrsCur
            for a1 in sinq( new ).select({$0.0}){
                r1.append(contentsOf: a1)
            }
            self.tpAddresses = test_tpToStringOfAddresses(r1)
            
            DispatchQueue.main.async {
                self.tableView.reloadData() // UITableViewController.tableView must be used from main thread only
            }
        }
        
        // 負責 因 addr 改變，設定 title
        _addrsCurChanged$.afterChange += { [weak self] (_, new) in
            guard let self = self else { return }
            
            let r1 = self._addrsCur
            let r2 = get_booknames_via_tp(tp: ManagerLangSet.s.curTpBookNameLang )[r1[0].book - 1]
            
            self.btnTitle.setTitle("\(r2) \(r1[0].chap)", for: .normal)
        }
        // 負責 因 addr 改變，取得資料，並且 trigger data& changed
        _addrsCurChanged$.afterChange += { [weak self] (_, new) in
            guard let self = self else { return }

            let r1 = self._addrsCur
            let r2 = get_booknames_via_tp(tp: ManagerLangSet.s.curTpBookNameLang )[r1[0].book - 1]
            let r3 = "\(r2)\(r1[0].chap)"
            // test1
            // ttvcl2021 ttvhl2021
            fhlQsb("strong=0&gb=0&version=ttvcl2021&qstr=\(r3)") { data in
//                print(data)
                if data.isSuccess() {
//                    print( sinq( data.record ).select({$0.bible_text}).joined(separator: "\n") )
                    
                    var oneLines: [DOneLine] = []
                    for a1 in data.record {
                        let oneLine = DOneLine()
                        let book = get_id_from_bookname(a1.engs, tp: .Matt)
                        oneLine.address2 = DAddress(book,a1.chap,a1.sec)
                        oneLine.children = [DText(a1.bible_text)]
                        oneLine.ver = "ttvcl2021"
                        oneLines.append(oneLine)
                    }
                    
                    let r2 = BibleText2DText().main(oneLines, "ttvcl2021")
                    
                    var results: DData = []
                    for a1 in r2{
                        let verserange = a1.addresses2!
                        let dtexts = a1.children!
                        results.append((verserange, dtexts))
                    }
                    
                    self.data$ <- results
                    
                    
                }
            }
        }
        
        self.tableView.dataSource = self
        
        // default
        _addrsCur = [DAddress(45,1,1)]
        _addrsCurChanged$ <- 0
    }
    // datasource
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data$.value.count
    }
    // datasource cell
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VCReadCell", for: indexPath) as! VCReadCell
        let dtexts: [DText] = [DText("仝此個所在有閣講：「𪜶絕對𣍐當進入我所賜的安歇。」",isTitle1: true),DText("這是一般文字")]
        
        let a1 = data$.value[indexPath.row]
        
        cell.labelText?.attributedText = DText_To_AttributedString(dtexts: a1.1, isSnVisible: false, isTCSupport: true)
        cell.labelVerse?.attributedText = to_string(addrs: a1.0, tp: self.tpAddresses)
        return cell
    }

    @IBAction func doPickBook(){
        let r1 = self.gVCBookChapPicker()
        r1.initBeforePushVC(_addrsCur[0].book, _addrsCur[0].chap)
        r1.onClick$.addCallback {[weak self] sender, pData in
            guard let self = self else { return }
            guard let data = pData else { return }
            
            self._addrsCur = DAddress(data.idBook, data.idChap, 1).generateEntireThisChap()
            self._addrsCurChanged$ <- (self._addrsCurChanged$.value + 1)
        }
        navigationController?.pushViewController(r1, animated: false)
    }
    @IBAction func doPlayAudio(){
        print("doPlayAudio")
    }
    
    
}
class VCReadCell : UITableViewCell{
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var labelVerse: UILabel!
    
}
