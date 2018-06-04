//
//  GameLevelSelectViewController.swift
//  Nanikore
//
//  Created by Kota Kawanishi on 2017/03/05.
//  Copyright © 2017年 Kota Kawanishi. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol GameLevelSelectViewControllerProtocol {
    func touchSound()
    func touchSound2()
    func moveViewControllerFromGameLevelSelectToGameRecord(stage: Stage)
    func moveViewControllerFromGameLevelSelectToTitle()
}


class GameLevelSelectViewController: UIViewController, StageButtonDelegate, GADBannerViewDelegate, GADInterstitialDelegate{
    
    enum Level: String{case Easy = "Easy", Normal = "Normal", Hard = "Hard"}
    let kNumberOfPassingPeopleClassKey = "NumberOfPassingPeople"
    let kLevelKey = "level"
    let kNumberKey = "number"
    
    //Views
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var mainBackgroundView: UIImageView!
    @IBOutlet weak var backHomeBtn: UIButton!
    var levelSelectView: UIImageView!
    var easyLevelBtn: UIButton!
    var normalLevelBtn: UIButton!
    var hardLevelBtn: UIButton!
    var backArrow: UIButton!
    var nextArrow: UIButton!
    var stageBtns: Array<StageButton>!
    var interstitial: GADInterstitial = GADInterstitial.init(adUnitID: "ca-app-pub-8719818866106636/2140084905")
    
    
    //Data
    var referenceSize: CGSize!
    var selectedLevel: Level!
    var pageNumber = 1
    var clearRecord: Array<Bool>!
    var clearNumberRecord: Array<Int>!
    var accessibleStage = 2
    var viewSetUpDone = false
    var dataLoadDone = false
    
    //Delegate
    var delegate: GameLevelSelectViewControllerProtocol!
    
    //Scale
    let backHomeBtnScale: TitleViewController.Scale = TitleViewController.Scale.init(xScale: 0.0402, yScale: 0.0288, sizeScale: 0.1839)
    let levelViewScale: TitleViewController.Scale = TitleViewController.Scale.init(yScale: 0.1538, widthScale: 0.8454, heightScale: 0.1025)
    let eachLevelScale: TitleViewController.Scale = TitleViewController.Scale.init(yScale: 0.3173, widthScale: 0.7246, heightScale: 0.1025)
    let eachLevelIntervalScale: CGFloat = 0.0439
    let stageBtnScale: TitleViewController.Scale = TitleViewController.Scale.init(yScale: 0.329, sizeScale:0.2979)
    let stageBtnHorizontalIntervalScale: CGFloat = 0.02415
    let stageBtnVerticalIntervalScale: CGFloat = 0.05017
    let arrowScale: TitleViewController.Scale = TitleViewController.Scale.init(xScale: 0.0289, yScale: 0.7749, widthScale: 0.2979, heightScale: 0.1025)
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.delegate = self.parent as! GameLevelSelectViewControllerProtocol
        referenceSize = self.view.frame.size
        self.interstialLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !viewSetUpDone{
            dataLoadDone = false
            self.configureViews()
            self.showBannerView()
            self.showInterstial()
            viewSetUpDone = true
        }
        viewSetUpDone = false
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureViews(){
        let levelSelectViewSize = CGSize(width: referenceSize.width * levelViewScale.widthScale, height: referenceSize.height * levelViewScale.heightScale)
        let levelSeletViewFrame = CGRect(x: referenceSize.width / 2.0 - levelSelectViewSize.width / 2.0, y: referenceSize.height * levelViewScale.yScale, width: levelSelectViewSize.width, height: levelSelectViewSize.height)
        
        let backHomeBtnFrame = CGRect(x: referenceSize.width * backHomeBtnScale.xScale, y: referenceSize.height * backHomeBtnScale.yScale, width: referenceSize.width * backHomeBtnScale.widthScale, height: referenceSize.width * backHomeBtnScale.widthScale)
        
        let levelBtnSize = CGSize(width: referenceSize.width * eachLevelScale.widthScale, height: referenceSize.height * eachLevelScale.heightScale)
        let easyLevelBtnFrame = CGRect(x: referenceSize.width / 2.0 - levelBtnSize.width / 2.0, y: referenceSize.height * eachLevelScale.yScale, width: levelBtnSize.width, height: levelBtnSize.height)
        let normalLevelBtnFrame = CGRect(x: easyLevelBtnFrame.minX, y: easyLevelBtnFrame.maxY + (referenceSize.height * eachLevelIntervalScale), width: levelBtnSize.width, height: levelBtnSize.height)
        let hardLevelBtnFrame = CGRect(x: easyLevelBtnFrame.minX, y: normalLevelBtnFrame.maxY + (referenceSize.height * eachLevelIntervalScale), width: levelBtnSize.width, height: levelBtnSize.height)
        
        levelSelectView = UIImageView.init(frame: levelSeletViewFrame)
        levelSelectView.image = #imageLiteral(resourceName: "LevelSelect")
        self.view.addSubview(levelSelectView)
        easyLevelBtn = UIButton(frame: easyLevelBtnFrame)
        easyLevelBtn.setImage(#imageLiteral(resourceName: "EasyLevel"), for: UIControlState.normal)
        easyLevelBtn.tag = 0
        easyLevelBtn.addTarget(self, action: #selector(touchOnLevelBtn(sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(easyLevelBtn)
        
        normalLevelBtn = UIButton(frame: normalLevelBtnFrame)
        normalLevelBtn.setImage(#imageLiteral(resourceName: "NormalLevel"), for: UIControlState.normal)
        normalLevelBtn.tag = 1
        normalLevelBtn.addTarget(self, action: #selector(self.touchOnLevelBtn(sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(normalLevelBtn)
        
        hardLevelBtn = UIButton(frame: hardLevelBtnFrame)
        hardLevelBtn.setImage(#imageLiteral(resourceName: "HardLevel"), for: UIControlState.normal)
        hardLevelBtn.tag = 2
        hardLevelBtn.addTarget(self, action: #selector(self.touchOnLevelBtn(sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(hardLevelBtn)
        
        backHomeBtn.frame = backHomeBtnFrame
    }
    
    @objc func touchOnLevelBtn(sender:UIButton){
        Thread.sleep(forTimeInterval: 0.1)
        removeLevelBtns()
        switch sender.tag {
        case 0:
            selectedLevel = Level.Easy
            levelSelectView.image = #imageLiteral(resourceName: "EasyLevel")
        case 1:
            selectedLevel = Level.Normal
            levelSelectView.image = #imageLiteral(resourceName: "NormalLevel")
        case 2:
            selectedLevel = Level.Hard
            levelSelectView.image = #imageLiteral(resourceName: "HardLevel")
            
        default:
            break
        }
        
        if !recordExists(){
            createRecord()
        }
        
        configureAccessibleStage()
        fetchClearNumberRecord()
        pageNumber = 1
        showArrows()
        showStageBtns()
    }
    
    func removeLevelBtns(){
        if easyLevelBtn.isDescendant(of: self.view){
            easyLevelBtn.removeFromSuperview()
            normalLevelBtn.removeFromSuperview()
            hardLevelBtn.removeFromSuperview()
        }
    }
    
    func recordExists() -> Bool {
        if UserDefaults.standard.object(forKey: selectedLevel.rawValue) != nil{
            clearRecord = UserDefaults.standard.array(forKey: selectedLevel.rawValue) as! Array<Bool>!
            return true
        }else{
            return false
        }
    }
    
    func createRecord(){
        var tempRecord = Array<Bool>()
        for _ in 0..<24{
            tempRecord.append(false)
        }
        clearRecord = tempRecord
        let defaults = UserDefaults.standard
        defaults.set(clearRecord, forKey: selectedLevel.rawValue)
        defaults.synchronize()
    }
    
    func fetchClearNumberRecord(){
        clearNumberRecord = Array<Int>()
        
        let query:NCMBQuery = NCMBQuery(className: kNumberOfPassingPeopleClassKey)
        query.whereKey(kLevelKey, equalTo: selectedLevel.rawValue)
        var results:[AnyObject] = []
        do {
            results = try query.findObjects() as [AnyObject]
        } catch  let error1 as NSError  {
            print("\(error1)")
            
        }
        if results.count > 0 {
            let clearRecord: NCMBObject = (results.first as? NCMBObject)!
            clearNumberRecord = clearRecord.object(forKey: kNumberKey) as! [Int]
            dataLoadDone = true
        }else{
            let alertController = UIAlertController(title: "データ取得失敗", message: "データを取得できませんでした。", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: {
                self.interstialLoad()
            })
        }
    }
    
    func configureAccessibleStage(){
        accessibleStage = 2
        repeat{
            if clearRecord[accessibleStage] == true{
                accessibleStage += 1
            }else{
                return
            }
        }while(accessibleStage < 23)
    }

    func showArrows(){
        if backArrow != nil{
            self.removeArrows()
        }else{
            let arrowFrame = CGRect(x: referenceSize.width * arrowScale.xScale, y: referenceSize.height * arrowScale.yScale, width: referenceSize.width * arrowScale.widthScale, height: referenceSize.height * arrowScale.heightScale)
            backArrow = UIButton.init(frame: arrowFrame)
            nextArrow = UIButton.init(frame: CGRect(x: referenceSize.width - arrowFrame.maxX, y: arrowFrame.minY, width: arrowFrame.width, height: arrowFrame.height))
            backArrow.setImage(#imageLiteral(resourceName: "BackArrow"), for: UIControlState.normal)
            nextArrow.setImage(#imageLiteral(resourceName: "NextArrow"), for: UIControlState.normal)
            backArrow.addTarget(self, action: #selector(backPage), for: UIControlEvents.touchUpInside)
            nextArrow.addTarget(self, action: #selector(nextPage), for: UIControlEvents.touchUpInside)
            
        }
        switch pageNumber{
        case 1: self.view.addSubview(nextArrow)
        case 2:
            self.view.addSubview(nextArrow)
            self.view.addSubview(backArrow)
        case 3:
            self.view.addSubview(nextArrow)
            self.view.addSubview(backArrow)
        case 4: self.view.addSubview(backArrow)
        default: break;
        }
    }
    
    func removeArrows(){
        if(backArrow != nil){
            if(backArrow.isDescendant(of: self.view)){
                backArrow.removeFromSuperview()
                
            }
            if(nextArrow.isDescendant(of: self.view)){
                nextArrow.removeFromSuperview()
                
            }
        }
    }
    
    @objc func nextPage(){
        self.delegate.touchSound()
        pageNumber += 1
        self.removeStageBtns()
        self.showStageBtns()
        self.showArrows()
    }
    
    @objc func backPage(){
        self.delegate.touchSound()
        pageNumber -= 1
        self.removeStageBtns()
        self.showStageBtns()
        self.showArrows()
    }
    
    func showStageBtns(){
        let horizontalIntervalLengthBetweenStageBtns = referenceSize.width * stageBtnHorizontalIntervalScale
        let verticalIntervalLengthBetweenStageBtns = referenceSize.height * stageBtnVerticalIntervalScale
        
        let horizontalWidth = referenceSize.width * stageBtnScale.widthScale * 3 + horizontalIntervalLengthBetweenStageBtns * 2
        
        let stageBtnX = self.view.frame.midX - horizontalWidth / 2.0
        
        stageBtns = Array<StageButton>.init()
        
        
        for i in 0..<6{
            stageBtns.append(StageButton.init(level: selectedLevel, stage: 6 * (pageNumber - 1) + i, clear: clearRecord[6 * (pageNumber - 1) + i], delegate: self))
        }
        
        let stageBtn1 = stageBtns[0]
        stageBtn1.frame = CGRect(x: stageBtnX, y: referenceSize.height * stageBtnScale.yScale, width: referenceSize.width * stageBtnScale.widthScale, height: referenceSize.width * stageBtnScale.widthScale)
        stageBtn1.addTarget(self, action: #selector(selectStage(stageButton:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(stageBtn1)
        
        for i in 1..<3{
            let stageBtn = stageBtns[i];
            let pStageBtn = stageBtns[i - 1];
            stageBtn.frame = CGRect(x: pStageBtn.frame.maxX + horizontalIntervalLengthBetweenStageBtns, y: pStageBtn.frame.minY, width: pStageBtn.frame.width, height: pStageBtn.frame.height)
            stageBtn.addTarget(self, action: #selector(selectStage(stageButton:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(stageBtn)
        }
        
        let stageBtn4 = stageBtns[3];
        
        stageBtn4.frame = CGRect(x: stageBtn1.frame.minX, y: stageBtn1.frame.maxY + verticalIntervalLengthBetweenStageBtns,width: stageBtn1.frame.width, height: stageBtn1.frame.height)
        
        stageBtn4.addTarget(self, action: #selector(selectStage(stageButton:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(stageBtn4)
        
        for i in 4..<6{
            let stageBtn = stageBtns[i];
            let pStageBtn = stageBtns[i - 1];
            stageBtn.frame = CGRect(x: pStageBtn.frame.maxX + horizontalIntervalLengthBetweenStageBtns, y: pStageBtn.frame.minY, width: pStageBtn.frame.width, height: pStageBtn.frame.height)
            stageBtn.addTarget(self, action: #selector(selectStage(stageButton:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(stageBtn)
        }
        
        self.configureStageBtns()
    }
    
    func configureStageBtns(){
        for i in 0..<6{
            let btn = stageBtns[i];
            if accessibleStage >= btn.stage.numberOfStage{
                btn.addStageStringImage()
                btn.addStageNumberView()
                btn.addSuccessfulCandidates(number: dataLoadDone ? clearNumberRecord[btn.stage.numberOfStage] : 0)
                if btn.stage.clear{
                    btn.addWellDoneStamp()
                }
            }else{
                btn.addStageLockView()
                btn.addSuccessfulCandidates(number: clearNumberRecord[btn.stage.numberOfStage])
                
            }
        }
    }
    
    func removeStageBtns(){
        if stageBtns != nil || stageBtns.count != 0{
            for i in 0..<6{
            let btn = stageBtns[i];
            btn.delegate = nil
            btn.removeFromSuperview()
            }
            stageBtns.removeAll()
        
            stageBtns = nil
        }
    }
    
    @objc func selectStage(stageButton: StageButton){
        self.delegate.touchSound()
        self.levelSelectView.removeFromSuperview()
        self.removeStageBtns()
        removeArrows()
        self.delegate.moveViewControllerFromGameLevelSelectToGameRecord(stage: stageButton.stage)
    }
    
    
    
    @IBAction func backHome(_ sender: Any) {
        self.delegate.touchSound2()
        self.levelSelectView.removeFromSuperview()
        if(stageBtns == nil){
           self.removeLevelBtns()
        }else{
            self.removeStageBtns()
        }
        self.removeArrows()
        self.delegate.moveViewControllerFromGameLevelSelectToTitle()
    }
    
    fileprivate func showBannerView(){
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.frame.origin = CGPoint.init(x: 0, y: referenceSize.height - bannerView.frame.height)
        bannerView.adUnitID = "ca-app-pub-8719818866106636/3549549708"
        bannerView.delegate = self as GADBannerViewDelegate
        bannerView.rootViewController = self
        let gadRequest:GADRequest = GADRequest()
        bannerView.load(gadRequest)
    }
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        viewSetUpDone = true
    }
    
    fileprivate func interstialLoad() {
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        interstitial.delegate = self
        interstitial.load(request)
    }
    
    fileprivate func showInterstial(){
        if interstitial.isReady && arc4random_uniform(3) == 0{
           interstitial.present(fromRootViewController: self)
        }
    }
    
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        viewSetUpDone = true
        
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
