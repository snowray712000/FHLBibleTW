//
//  VCRead.swift
//  FHLBibleTW
//
//  Created by littlesnow on 2024/1/7.
//

import Foundation
import UIKit
import FHLCommon
import AVFoundation

class ManagerAddress : NSObject {
    static var s: ManagerAddress = ManagerAddress()
    var _cur: [DAddress]? = nil    /**
        更新到 UserDefault 中
     */
    func update(_ addrs:[DAddress]){
        self._cur = addrs
        
        let r1 = VerseRangeToString().main(addrs, .Mt)
        UserDefaults.standard.set(r1, forKey: "AddressCurrent")
    }
    func cur()->[DAddress] {
        if _cur == nil {
            guard let r1 = UserDefaults.standard.string(forKey: "AddressCurrent") else {
                return [DAddress(45,1,1)]
            }
            let r2 = StringToVerseRange().main(r1,(45,1))
            self._cur = r2
            return self._cur!
        } else {
            return _cur!
        }
    }
}
class ManagerTpVersion : NSObject {
    static var s: ManagerTpVersion = ManagerTpVersion()
    var _cur: Int? = nil
    func cur()-> Int {
        if _cur == nil {
            _cur = UserDefaults.standard.integer(forKey: "TpVersion") // int 若不存在會回傳 0
        }
        return _cur!
    }
    func update(_ v: Int){
        self._cur = v
        UserDefaults.standard.set(v, forKey: "TpVersion")
    }
}

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
    var tpVersion = ManagerTpVersion.s.cur()
    // getter
    var versionsFromTp: [String] {
        get {
            let vers = ["ttvhl2021","ttvcl2021"]
            if tpVersion == 0 {
                return [vers[0]]
            } else if tpVersion == 1 {
                return [vers[1]]
            } else {
                return vers
            }
        }
    }
    
    /**
     當 data$ 變更時，會更新一次。在計算某 row cell 時，會用到。(雖然可以每次都計算，但應該是 data 算一次時就夠了)
     */
    var tpAddresses: TpToStringOfAddresses = .none
    
    var _addrsCur: VerseRange = [DAddress(45,1,1)]
    var _addrsCurChanged$: Observable<Int> = Observable(0)
    lazy var _swipeHelper: SwipeHelp = SwipeHelp(view: self.view)
    @IBOutlet weak var btnTitle: UIButton!
    @IBOutlet weak var btnMore2: UIBarButtonItem!
    @IBOutlet weak var btnAudio: UIBarButtonItem!
    lazy var viewDisappearing =  EasyEventAppBackgroundForegroundSwitch()
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDisappearing.evResignActive$.afterChange += { [weak self] (_ , _) in
            print("resign")
            self?.setPlayerNil()
        }
        // 還沒開發，發版本前，先隱藏起來
//        btnMore2.setValue(true, forKey: "hidden")
        
        _swipeHelper.addSwipe(dir: .left)
        _swipeHelper.addSwipe(dir: .right)
        _swipeHelper.onSwipe$.afterChange += { [weak self] (_, new) in
            guard let self = self else { return }
            if new.direction == .right {
                let addrs = FHLCommon.VerseRangeGoNextChap().goPrev(self._addrsCur)
                self._addrsCur = addrs
                self._addrsCurChanged$.value += 1
            } else if new.direction == .left {
                let addrs = FHLCommon.VerseRangeGoNextChap().goNext(self._addrsCur)
                self._addrsCur = addrs
                self._addrsCurChanged$.value += 1
            }
        }
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
        _addrsCurChanged$.afterChange += { [weak self] (_, new) in
            guard let self = self else { return }
            ManagerAddress.s.update(self._addrsCur)
        }
        _addrsCurChanged$.afterChange += { [weak self] (_, new) in
            self?.setPlayerNil()
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
            // 抓取資料中
            var tmpData: DData = []
            tmpData.append((self._addrsCur, [DText("載入中...")]))
            self.data$ <- tmpData
            
            // 這樣才會先更新上面的外皮
            DispatchQueue.global().async {
                // 預備參數
                let r1 = self._addrsCur
                let r2 = get_booknames_via_tp(tp: .太 )[r1[0].book - 1] // 台語都是用 .太
                let r3 = "\(r2)\(r1[0].chap)"
                
                let vers = self.versionsFromTp
                
                // 同步處理
                // 產生一個 dictResultOfQsb 給 dictResultOfQsb[ver]=結果
                var dictResultOfQsb: [String: DData] = [:]
                
                let group = DispatchGroup()
                for ver in vers{
                    group.enter()
                    // 取得
                    let qsbStr = "strong=0&gb=0&version=\(ver)&qstr=\(r3)"
                    // try
                    fhlQsb(qsbStr) { data in
                        // print(data)
                        if data.isSuccess() {
                            // print( sinq( data.record ).select({$0.bible_text}).joined(separator: "\n") )
                            if data.record.count == 0 {
                                let reNoData: DData = [(r1, [DText("未成功取得資料 " + ver , isParenthesesHW: true)])]
                                dictResultOfQsb[ver] = reNoData
                            } else {
                                var oneLines: [DOneLine] = []
                                for a1 in data.record {
                                    let oneLine = DOneLine()
                                    let book = get_id_from_bookname(a1.engs, tp: .Matt)
                                    oneLine.address2 = DAddress(book,a1.chap,a1.sec)
                                    oneLine.children = [DText(a1.bible_text)]
                                    oneLine.ver = ver
                                    oneLines.append(oneLine)
                                }
                                
                                let r2 = BibleText2DText().main(oneLines, ver)
                                
                                var results: DData = []
                                for a1 in r2{
                                    let verserange = a1.addresses2!
                                    let dtexts = a1.children!
                                    results.append((verserange, dtexts))
                                }
                                dictResultOfQsb[ver] = results
                            }
                        }
                        group.leave()
                    }
                }
                
                // 等全部都取好
                group.notify(queue: .main){
                    // 兩個都取好之後. 合併動作
                    
                    // dictResultOfQsb 轉為 array 按 vers 順序，交錯排序
                    var results: DData = []
                    
                    // 先判斷，最大的 count 數
                    let count = sinq(vers).select({dictResultOfQsb[$0]?.count ?? 0}).max() ?? 0
                    
                    // 交錯插入
                    for i in 0..<count{
                        for ver in vers{
                            let r1 = dictResultOfQsb[ver]
                            if r1 != nil && i < r1!.count {
                                let a1 = r1![i]
                                results.append(a1)
                            }
                        }
                    }
                    
                    self.data$ <- results
                }
            }
            
        }
        
        self.tableView.dataSource = self
        
        // default
        tpVersion = ManagerTpVersion.s.cur()
        _addrsCur = ManagerAddress.s.cur()
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
    
    var avPlayer: AVPlayer?
    var playerItemContext = 1
    var playerItemDidPlayToEndTimeObserver: Any?
    @IBAction func doPlayAudio(){
        if avPlayer == nil {
            print("doPlayAudio")
            
            let addr = _addrsCur[0]
            let chapString = String(format: "%03d", addr.chap)
            let mp3_urla = "https://media.fhl.net/tte/\(addr.book)/\(addr.book)_\(chapString).mp3"
            guard let mp3_url = URL(string: mp3_urla) else {
                print("error mp3 url \(mp3_urla)")
                return
            }
            
            self.setPlayer(url: mp3_url)
        } else {
            assert( self.avPlayer != nil && self.avPlayer!.currentItem != nil )
            self.setPlayerNil()// player.rate = 1.0 // readyToPlay 事件時播放
        }
    }
    
    func setPlayer(url: URL){
        let item_player = AVPlayerItem(url: url)
        addObserver_avplayitem_status(palyerItem: item_player)
        addObserver_avplayitem_completed(playerItem: item_player)
        
        let player = AVPlayer(playerItem: item_player)
        
        // player.rate = 1.0 // readyToPlay 事件時播放
        self.avPlayer = player
        
    }
    func setPlayerNil(){
        if let player = self.avPlayer,
           let item = player.currentItem{
            removeObserver_avplayitem_status(palyerItem: item)
            removeObserver_avplayitem_completed(playerItem: item)
            player.rate = 0
            self.avPlayer = nil
        }
    }
    func addObserver_avplayitem_completed(playerItem: AVPlayerItem){
        assert ( playerItemDidPlayToEndTimeObserver == nil )
        // 沒有把 回傳值 存起來 也會成功加入，但回傳值存起來，在 remove 時相對方便
        playerItemDidPlayToEndTimeObserver =
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] notification in
            self?.setPlayerNil()
        }
    }
    func removeObserver_avplayitem_completed(playerItem: AVPlayerItem){
        assert( playerItemDidPlayToEndTimeObserver != nil )
        NotificationCenter.default.removeObserver(playerItemDidPlayToEndTimeObserver!)
        playerItemDidPlayToEndTimeObserver = nil
    }
    func addObserver_avplayitem_status(palyerItem: AVPlayerItem){
        palyerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new, .old], context: &playerItemContext)
    }
    func removeObserver_avplayitem_status(palyerItem: AVPlayerItem){
        palyerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &playerItemContext)
    }
    func observeValue_playitem(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        // 通常，一開始會是 0，變成 1
        // 發生在 初始一個 AVPlayer(item) 時會觸發，而不是 .rate = 1 才觸發
        
        assert( keyPath == "status" )
        if let change = change,
           let newValue = change[.newKey] as? Int,
           let oldValue = change[.oldKey] as? Int{
            
            let newStatus = AVPlayerItem.Status(rawValue: newValue)
            let oldStatus = AVPlayerItem.Status(rawValue: oldValue)
//            print("status: \(status), st2: \(st2)")}
            
            switch newStatus {
            case .readyToPlay: // 1
                print("readyToPlay")
                if let player = self.avPlayer,
                   let item = player.currentItem {
                    player.rate = 1.0
//                    print( item.duration ) // CMTime(value: 14626944, timescale: 44100, flags: __C.CMTimeFlags(rawValue: 1), epoch: 0)
//                    print( item.currentTime() ) // CMTime(value: 0, timescale: 1, flags: __C.CMTimeFlags(rawValue: 1), epoch: 0)
//                    let time2 = CMTime(seconds: item.duration.seconds - 1, preferredTimescale: item.duration.timescale)
//                    player.seek(to: time2, toleranceBefore: .zero, toleranceAfter: .zero)
                    // 到結束前一秒
                    //                let time = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                    //                self.avPlayer!.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
                }
                
                
                break
            case .unknown: // 0
                print("unknown")
                break
            case .failed:// 2
                print("failed")
                break
            default:
                print("default")
                break
            }
        }
    }
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &playerItemContext {
            observeValue_playitem(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }    
    
    @IBAction func doClickMore2(){
        print("doMore")
        print("doPlayAudio")
        guard let mp3_url = URL(string: "https://media.fhl.net/tte/2/2_002.mp3") else { return }

        let item_player = AVPlayerItem(url: mp3_url)
        let player = AVPlayer(playerItem: item_player)
        player.rate = 1
    }
    @IBAction func doSwitchVersions(){
        self.tpVersion += 1
        if self.tpVersion > 2{
            self.tpVersion = 0
        }
              
        ManagerTpVersion.s.update(self.tpVersion)
        _addrsCurChanged$ <- (_addrsCurChanged$.value + 1)
    }
}
class VCReadCell : UITableViewCell{
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var labelVerse: UILabel!
    
}
/// 手勢，向左滑 向右滑
/// lazy var _swipeHelp = SwipeHelp(view: self.view)
class SwipeHelp {
    init(view: UIView){
        self.view = view
    }
    // 加上 lazy 就能使用 self
    lazy var onSwipe$: Observable<UISwipeGestureRecognizer> = Observable(UISwipeGestureRecognizer(target: self, action: #selector(doSwipe(sender:))))
    
    private var view: UIView!
    func addSwipe(dir: UISwipeGestureRecognizer.Direction, numberOfTouches: Int = 1){
        let r1 = UISwipeGestureRecognizer(target: self, action: #selector(doSwipe(sender:)))
        r1.direction = dir
        r1.numberOfTouchesRequired = numberOfTouches
        view.addGestureRecognizer(r1)
        
        _gestures.append(r1)
    }
    @objc private func doSwipe(sender: UISwipeGestureRecognizer){
        onSwipe$ <- sender
     }
    private var _gestures: [UISwipeGestureRecognizer] = []
}
class EasyEventAppBackgroundForegroundSwitch {
    /// 程式從主畫面切回來時，會觸發
    /// .evBecomeActive$.afterChange += { [weak self] (_ , _) in }
    var evBecomeActive$: Observable<Int> = Observable(0)
    /// 程式縮到最小時會觸發
    /// .evResignActive$.afterChange += { [weak self] (_ , _) in }
    var evResignActive$: Observable<Int> = Observable(0)
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    @objc func handleResignActiveNotification() {
        evResignActive$.value += 1
    }
    @objc func handleBecomeActiveNotification() {
        evBecomeActive$.value += 1
    }
    deinit{
        evBecomeActive$.afterChange.removeAll()
        evBecomeActive$.beforeChange.removeAll()
        evResignActive$.afterChange.removeAll()
        evResignActive$.beforeChange.removeAll()
    }
}
