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
    
    let r1 = "\(addrs[0].verse)-\(addrs[addrs.count-1].verse)"
    return DText_To_AttributedString(dtexts: [DText(r1)], isSnVisible: false, isTCSupport: true)
}
public class VCRead: UITableViewController {
    typealias VerseRange = [DAddress]
    typealias DData = [(VerseRange,[DText])]
    var data$: Observable<DData> = Observable([])
    
    /**
     當 data$ 變更時，會更新一次。在計算某 row cell 時，會用到。(雖然可以每次都計算，但應該是 data 算一次時就夠了)
     */
    var tpAddresses: TpToStringOfAddresses = .none
    
    var _addrsCur: VerseRange = []
    var _addrsCurChanged$: Observable<Int> = Observable(0)
    
    @IBOutlet weak var btnTitle: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        btnTitle.setTitle("TEST", for: .normal)
        
        data$.afterChange += { [weak self] (_, new) in
            guard let self = self else { return }
            
            // update tpAddresses
            var r1:[DAddress] = self._addrsCur
            for a1 in sinq( new ).select({$0.0}){
                r1.append(contentsOf: a1)
            }
            self.tpAddresses = test_tpToStringOfAddresses(r1)
            
            self.tableView.reloadData()
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
            print(r3)
            // test1
            // ttvcl2021 ttvhl2021
            fhlQsb("strong=0&gb=0&version=ttvhl2021&qstr=\(r3)") { data in
                print(data)
                if data.isSuccess() {
                    print( sinq( data.record ).select({$0.bible_text}).joined(separator: "\n") )
                }
            }
        }
        
        self.tableView.dataSource = self
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
