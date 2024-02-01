//
//  VCRead.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/7.
//

import Foundation
import UIKit

class VCRead: UITableViewController {
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
        
        let ob1 = data$.afterChange += { [weak self] (old, new) in
            
            // update tpAddresses
            var r1:[DAddress] = []
            sinq( new ).select({$0.0}).each { VerseRange in
                r1.append(contentsOf: VerseRange.verses)
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
        cell.labelText?.attributedText = to_attributedString(a1.1)
        cell.labelVerse?.text = to_string(a1.0, tp: self.tpAddresses)
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
