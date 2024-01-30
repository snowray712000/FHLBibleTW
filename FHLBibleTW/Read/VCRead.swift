//
//  VCRead.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/7.
//

import Foundation
import UIKit


class VCRead: UITableViewController {
    
    @IBOutlet weak var btnTitle: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnTitle.setTitle("TEST", for: .normal)
        
        self.tableView.dataSource = self
    }
    // datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    // datasource cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VCReadCell", for: indexPath) as! VCReadCell
        cell.labelText?.text =  "仝此個所在有閣講：「𪜶絕對𣍐當進入我所賜的安歇。」"        
        cell.labelVerse?.text = "1"
        return cell
    }
    
    @IBAction func doPickBook(){
        print("doPickBook")
    }
    @IBAction func doPlayAudio(){
        print("doPlayAudio")
    }
    
    
}
class VCReadCell : UITableViewCell{
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var labelVerse: UILabel!
    
}
