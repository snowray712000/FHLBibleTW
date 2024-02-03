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
class VCRead: UITableViewController {
    typealias VerseRange = [DAddress]
    typealias DData = [(VerseRange,[DText])]
    var data$: Observable<DData> = Observable([])
    
    /**
     當 data$ 變更時，會更新一次。在計算某 row cell 時，會用到。(雖然可以每次都計算，但應該是 data 算一次時就夠了)
     */
    var tpAddresses: TpToStringOfAddresses = .none
    
    @IBOutlet weak var btnTitle: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnTitle.setTitle("TEST", for: .normal)
        
        data$.afterChange += { [weak self] (_, new) in
            
            // update tpAddresses
            var r1:[DAddress] = []
            for a1 in sinq( new ).select({$0.0}){
                r1.append(contentsOf: a1)
            }
            self?.tpAddresses = test_tpToStringOfAddresses(r1)
            
            self?.tableView.reloadData()
        }
        
        self.tableView.dataSource = self
    }
    // datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data$.value.count
    }
    // datasource cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VCReadCell", for: indexPath) as! VCReadCell
        let dtexts: [DText] = [DText("仝此個所在有閣講：「𪜶絕對𣍐當進入我所賜的安歇。」",isTitle1: true),DText("這是一般文字")]
        
        let a1 = data$.value[indexPath.row]
        
        cell.labelText?.attributedText = DText_To_AttributedString(dtexts: a1.1, isSnVisible: false, isTCSupport: true)
        cell.labelVerse?.attributedText = to_string(addrs: a1.0, tp: self.tpAddresses)
        return cell
    }
    
    
    @IBAction func doPickBook(){
        print("doPickBook")
        
        fhlQsb("strong=0&gb=0&version=ttvh&qstr=詩134") { data in
            print(data)
            if data.isSuccess() {
                print( sinq( data.record ).select({$0.bible_text}).joined(separator: "\n") )                            
            }
        }
    }
    @IBAction func doPlayAudio(){
        print("doPlayAudio")
    }
    
    
}
class VCReadCell : UITableViewCell{
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var labelVerse: UILabel!
    
}
