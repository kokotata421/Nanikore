//
//  GameOverViewController.swift
//  Nanikore
//
//  Created by Kota Kawanishi on 2017/03/05.
//  Copyright © 2017年 Kota Kawanishi. All rights reserved.
//

import UIKit
import GoogleMobileAds


protocol GameOverViewControllerProtocol{
    func touchSound()
    func successSound()
    func failureSound()
    func stampSound()
    func moveViewControllerFromGameOverToTitle()
    func moveViewControllerFromGameOverToGame(stage: Stage)
    func moveViewControllerFromGameOverToAnswer()
    func stopBGM()
}

class GameOverViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate{
    
    //Views
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var nextStageBtn: UIButton!
    @IBOutlet weak var playAgainBtn: UIButton!
    @IBOutlet weak var checkAnswerBtn: UIButton!
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var levelStageLabel: UIImageView!
    @IBOutlet weak var mainBackgroundView: UIImageView!
    var sealView: UIImageView!
    var resultStamp: UIImageView!
    var resultString: UIImageView!
    
    
    //Data
    var stage: Stage!
    var recordTime: Int!
    var resultProcedureDone = false
    var result: Bool!
    var referenceSize: CGSize!
    
    //Delegate
    var delegate: GameOverViewControllerProtocol!
    
    //Others
    let kRankOfRecordKey = "rankOfRecord"
    let kNumberOfPassingPeopleKey = "numberOfPassingPeople"
    let kNumberOfPassingPeopleClassKey = "NumberOfPassingPeople"
    let kStageKey = "stage"
    let kStageRecordKey = "StageRecord"
    let kLevelKey = "level"
    let kNumberKey = "number"
    let interstitial = GADInterstitial.init(adUnitID: "ca-app-pub-8719818866106636/9735037302")
    
    
    //Scale
    let resultStampScale = TitleViewController.Scale.init(yScale: 0.23, widthScale: 0.6119, heightScale: 0.2929)
    let sealScale = TitleViewController.Scale.init(widthScale: 0.6119, heightScale: 0.5468)
    let nextBtnScale = TitleViewController.Scale.init(yScale: 0.5913, widthScale: 0.3621, heightScale: 0.0908)
    let intervalScaleOfBtns: CGFloat = 0.0302
    let failureStringScale = TitleViewController.Scale.init(yScale: 0.1508, widthScale: 0.3019, heightScale: 0.05015)
    let passStringScale = TitleViewController.Scale.init(yScale: 0.1508, widthScale: 0.2012, heightScale: 0.05015)
    let levelStageLabelScale = TitleViewController.Scale.init(yScale: 0.0439, widthScale: 0.9742, heightScale: 0.0705)
    let easyStringScale = TitleViewController.Scale.init(xScale: 0.4342, widthScale: 0.2198, heightScale: 0.461)
    let normalStringScale = TitleViewController.Scale.init(xScale: 0.44895, widthScale: 0.1771, heightScale: 0.461)
    let hardStringScale = TitleViewController.Scale.init(xScale: 0.4296, widthScale: 0.2334, heightScale: 0.461)
    let numberSizeScale = TitleViewController.Scale.init(widthScale: 0.0346, heightScale: 0.451)
    let number1SizeScale = TitleViewController.Scale.init(widthScale: 0.0185, heightScale: 0.451)
    let numberXScale: [CGFloat] = [0.9343, 0.89015]
    let additionOfNumber1XScale: CGFloat = 0.00305


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        referenceSize = self.view.frame.size
        self.delegate = self.parent! as! GameOverViewControllerProtocol
        self.interstialLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        if !resultProcedureDone{
            self.configureViews()
            self.delegate.stopBGM()
            self.resultSound()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {self.startResultAnimation()})
            self.showBannerView()
            resultProcedureDone = true
        }
        resultProcedureDone = false
    }
    
    func configureViews(){
        var resultStringSize: CGSize!
        if(result){
            resultString = UIImageView.init(image: #imageLiteral(resourceName: "PassLabel"))
            resultStamp = UIImageView.init(image:#imageLiteral(resourceName: "WellDone"))
            resultStringSize = CGSize.init(width: referenceSize.width * passStringScale.widthScale, height: referenceSize.height * passStringScale.heightScale)
        }else{
            resultString = UIImageView.init(image: #imageLiteral(resourceName: "FailureLabel"))
            resultStamp = UIImageView.init(image: #imageLiteral(resourceName: "TryAgain"))
            resultStringSize = CGSize.init(width: referenceSize.width * failureStringScale.widthScale, height: referenceSize.height * failureStringScale.heightScale)
        }
        let resultStringFrame = CGRect.init(x: referenceSize.width / 2.0 - resultStringSize.width / 2.0, y: referenceSize.height * passStringScale.yScale, width: resultStringSize.width, height: resultStringSize.height)
        let resultStampSize = CGSize.init(width: referenceSize.width * resultStampScale.widthScale, height: referenceSize.height * resultStampScale.heightScale)
        let resultStampFrame = CGRect.init(x: referenceSize.width / 2.0 - resultStampSize.width / 2.0, y: referenceSize.height * resultStampScale.yScale, width: resultStampSize.width, height: resultStampSize.height)
        resultString.frame = resultStringFrame
        resultStamp.frame = resultStampFrame
        sealView = UIImageView.init(image: #imageLiteral(resourceName: "Seal"))
        let sealSize = CGSize.init(width: resultStampFrame.width, height: referenceSize.height * sealScale.heightScale)
        sealView.frame = CGRect.init(x: resultStampFrame.minX, y: 0 - sealSize.height, width: sealSize.width, height: sealSize.height)
        sealView.transform = sealView.transform.scaledBy(x: 1.1, y: 1.0)
        self.showLevelStageLabel()
        self.view.addSubview(sealView)

    }
    
    func configureBtns(){
        let btnSize = CGSize.init(width: referenceSize.width * nextBtnScale.widthScale, height: referenceSize.height * nextBtnScale.heightScale)
        if(result && (stage.level != GameLevelSelectViewController.Level.Hard || stage.numberOfStage < 23)){
            nextStageBtn.frame = CGRect.init(x: referenceSize.width / 2.0 - btnSize.width - referenceSize.width * intervalScaleOfBtns / 2.0, y: referenceSize.height * nextBtnScale.yScale, width: btnSize.width, height: btnSize.height)
            nextStageBtn.isHidden = false
            nextStageBtn.isUserInteractionEnabled = true
            playAgainBtn.frame = CGRect.init(x: nextStageBtn.frame.maxX + referenceSize.width * intervalScaleOfBtns, y: nextStageBtn.frame.minY, width: btnSize.width, height: btnSize.height)
            playAgainBtn.isHidden = false
            playAgainBtn.isUserInteractionEnabled = true
        }else{
            nextStageBtn.isHidden = true
            nextStageBtn.isUserInteractionEnabled = false
            playAgainBtn.frame = CGRect.init(x: referenceSize.width / 2.0 - btnSize.width / 2.0, y: referenceSize.height * nextBtnScale.yScale, width: btnSize.width, height: btnSize.height)
            
            playAgainBtn.isHidden = false
            playAgainBtn.isUserInteractionEnabled = true
        }
        checkAnswerBtn.frame = CGRect.init(x: referenceSize.width / 2.0 - btnSize.width - referenceSize.width * intervalScaleOfBtns / 2.0, y: playAgainBtn.frame.maxY + referenceSize.width * intervalScaleOfBtns, width: btnSize.width, height: btnSize.height)
        
        titleBtn.frame = CGRect.init(x: checkAnswerBtn.frame.maxX + referenceSize.width * intervalScaleOfBtns, y: checkAnswerBtn.frame.minY, width: btnSize.width, height: btnSize.height)

        titleBtn.isHidden = false
        checkAnswerBtn.isHidden = false
        titleBtn.isUserInteractionEnabled = true
        checkAnswerBtn.isUserInteractionEnabled = true
    }
    
    func showLevelStageLabel(){
        let levelStageLabelSize = CGSize.init(width: referenceSize.width * levelStageLabelScale.widthScale, height: referenceSize.height * levelStageLabelScale.heightScale)
        levelStageLabel.frame = CGRect.init(x: referenceSize.width / 2.0 - levelStageLabelSize.width / 2.0, y: referenceSize.height * levelStageLabelScale.yScale, width: levelStageLabelSize.width, height: levelStageLabelSize.height)
        
        self.view.addSubview(levelStageLabel)
        switch stage.level{
        case .Easy:
            let easyStringLabel = UIImageView.init(image: #imageLiteral(resourceName: "EasyString"))
            let easyStringSize = CGSize.init(width: levelStageLabelSize.width * easyStringScale.widthScale, height: levelStageLabelSize.height * easyStringScale.heightScale)
            let easyStringFrame = CGRect.init(x: levelStageLabel.frame.width * easyStringScale.xScale, y: levelStageLabel.bounds.midY - easyStringSize.height / 2.0, width: easyStringSize.width, height: easyStringSize.height)
            easyStringLabel.frame = easyStringFrame
            levelStageLabel.addSubview(easyStringLabel)
        case .Normal:
            let normalStringLabel = UIImageView.init(image: #imageLiteral(resourceName: "NormalString"))
            let normalStringSize = CGSize.init(width: levelStageLabelSize.width * normalStringScale.widthScale, height: levelStageLabelSize.height * normalStringScale.heightScale)
            let normalStringFrame = CGRect.init(x: levelStageLabel.frame.width * normalStringScale.xScale, y: levelStageLabel.bounds.midY - normalStringSize.height / 2.0, width: normalStringSize.width, height: normalStringSize.height)
            normalStringLabel.frame = normalStringFrame
            levelStageLabel.addSubview(normalStringLabel)
        case .Hard:
            let hardStringLabel = UIImageView.init(image: #imageLiteral(resourceName: "HardString"))
            let hardStringSize = CGSize.init(width: levelStageLabelSize.width * hardStringScale.widthScale,height: levelStageLabelSize.height * hardStringScale.heightScale)
            let hardStringFrame = CGRect.init(x: levelStageLabel.frame.width * hardStringScale.xScale, y: levelStageLabel.bounds.midY - hardStringSize.height / 2.0, width: hardStringSize.width, height: hardStringSize.height)
            hardStringLabel.frame = hardStringFrame
            levelStageLabel.addSubview(hardStringLabel)
        }
        showNumberOnLevelStageLabel()
    }
    
    func showNumberOnLevelStageLabel(){
        var tempNumber = stage.numberOfStage + 1
        for i in 0..<2{
            var stageNumberImageString: String!
            var stageNumberImage: UIImage!
            var stageNumberViewFrame: CGRect!
            
            if(i == 1 && stage.numberOfStage < 9){
                stageNumberImage = #imageLiteral(resourceName: "Number0OnLevelStageLabel")
            }else{
                stageNumberImageString = String.init(format: "Number%dOnLevelStageLabel", tempNumber % 10)
                stageNumberImage = UIImage.init(named: stageNumberImageString)
            }
            if(tempNumber % 10 == 1){
                let stageNumberViewSize = CGSize.init(width: levelStageLabel.frame.width * number1SizeScale.widthScale, height: levelStageLabel.frame.height * number1SizeScale.heightScale)
                stageNumberViewFrame = CGRect(x: levelStageLabel.frame.width * (numberXScale[i] + additionOfNumber1XScale), y: levelStageLabel.bounds.midY - stageNumberViewSize.height / 2.0, width: stageNumberViewSize.width, height: stageNumberViewSize.height)
            }else{
                let stageNumberViewSize = CGSize.init(width: levelStageLabel.frame.width * numberSizeScale.widthScale, height: levelStageLabel.bounds.height * numberSizeScale.heightScale)
                stageNumberViewFrame = CGRect(x: levelStageLabel.frame.width * numberXScale[i], y: levelStageLabel.bounds.midY - stageNumberViewSize.height / 2.0, width: stageNumberViewSize.width, height: stageNumberViewSize.height)
            }
            let stageNumberView = UIImageView.init(frame: stageNumberViewFrame)
            stageNumberView.image = stageNumberImage
            levelStageLabel.addSubview(stageNumberView)
            tempNumber /= 10
        }
    }
    
    func startResultAnimation(){
        UIView.animate(withDuration: 1.4, animations: {()->Void in
            self.sealView.transform = self.sealView.transform.scaledBy(x: 1.0, y: 1.0)
            self.sealView.frame.origin.y = self.resultStamp.frame.maxY - self.sealView.frame.height
        }, completion: {(finished: Bool) -> Void in
            self.delegate.stampSound()
            self.view.addSubview(self.resultStamp)
            self.view.addSubview(self.resultString)
            self.sealView.removeFromSuperview()
            self.configureBtns()
            self.showInterstial()
            if self.result{
                self.updateRecord()
            }
        })
    }
    
    func updateRecord(){
       // updateGeneralRecord()
        updateSelfRecord()
    }
    
    func updateGeneralRecord(){
        let defaults = UserDefaults.standard
        let query:NCMBQuery = NCMBQuery(className: kStageRecordKey)
        query.whereKey(kStageKey, equalTo: stage.level.rawValue + String(stage.numberOfStage + 1))
        var results:[AnyObject] = []
        do {
            results = try query.findObjects() as [AnyObject]
        } catch  let error1 as NSError  {
            print("\(error1)")
            
        }
        if results.count > 0 {
            let stageRecord: NCMBObject = (results.first as? NCMBObject)!
            var timeRecords = stageRecord.object(forKey: kRankOfRecordKey) as! [Int]
            if(timeRecords.first != nil){
                if(timeRecords.first == 0){
                    timeRecords.removeAll()
                }
            }
            timeRecords.append(recordTime)
            if defaults.bool(forKey: "unprocessed"){
                let records:Array<Int> = defaults.array(forKey: "unprocessedRecord") as! Array<Int>
                for record in records{
                    timeRecords.append(record)
                }
                defaults.set(false, forKey: "unprocessed")
                defaults.set(nil, forKey: "unprocessedRecord")
                defaults.synchronize()
            }
            var newRecord = timeRecords.sorted(by: {$0 < $1})
            if newRecord.count > 5{
                newRecord.removeLast()
            }
            stageRecord.setObject(newRecord, forKey: kRankOfRecordKey)
            stageRecord.saveInBackground(nil)
            var resultRecord = defaults.array(forKey: stage.level.rawValue) as! Array<Bool>
            if !resultRecord[stage.numberOfStage]{
                let query:NCMBQuery = NCMBQuery(className: kNumberOfPassingPeopleClassKey)
                var resultsOfNumber:[AnyObject] = []
                query.whereKey(kLevelKey, equalTo: stage.level.rawValue)
                do {
                    resultsOfNumber = try query.findObjects() as [AnyObject]
                } catch  let error1 as NSError  {
                    print("\(error1)")
                    
                }
                if resultsOfNumber.count > 0 {
                    let numberOfPassingPeopleRecord = (resultsOfNumber.first as? NCMBObject)!
                    var numberRecord: [Int] = numberOfPassingPeopleRecord.object(forKey: kNumberKey) as! [Int]
                    numberRecord[stage.numberOfStage] += 1
                    numberOfPassingPeopleRecord.setObject(numberRecord, forKey: kNumberKey)
                    numberOfPassingPeopleRecord.saveInBackground(nil)
                }else{
                    let result = defaults.bool(forKey: "unprocessed")
                    if result{
                        var record:Array<Int> = defaults.array(forKey: "unprocessedRecord") as! Array<Int>
                        record.append(recordTime)
                        defaults.set(record, forKey: "unprocessedRecord")
                        defaults.synchronize()
                    }else{
                        if (recordTime != nil){
                            let record: Array<Int> = [recordTime]
                            defaults.set(true, forKey: "unprocessed")
                            defaults.set(record, forKey: "unprocessedRecord")
                            defaults.synchronize()
                        }
                        
                    }
                    
                    let alertController = UIAlertController(title: "データ保存失敗", message: "データを保存できませんでした。", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: {
                    })
                }
            }
        }else{
            let result = defaults.bool(forKey: "unprocessed")
            if result{
                var record:Array<Int> = defaults.array(forKey: "unprocessedRecord") as! Array<Int>
                record.append(recordTime)
                defaults.set(record, forKey: "unprocessedRecord")
                defaults.synchronize()
            }else{
                if (recordTime != nil){
                    let record: Array<Int> = [recordTime]
                    defaults.set(true, forKey: "unprocessed")
                    defaults.set(record, forKey: "unprocessedRecord")
                    defaults.synchronize()
                }
                
            }
            
            let alertController = UIAlertController(title: "データ保存失敗", message: "データを保存できませんでした。", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: {
            })
        }
    }
    
    func updateSelfRecord(){
        let defaults = UserDefaults.standard
        
        var resultRecord = defaults.array(forKey: stage.level.rawValue) as! Array<Bool>
        if !resultRecord[stage.numberOfStage]{
            resultRecord[stage.numberOfStage] = true
        }
        defaults.set(resultRecord, forKey: stage.level.rawValue)
        
        if UserDefaults.standard.object(forKey: stage.level.rawValue + (String(stage.numberOfStage + 1))) != nil{
            var selfTimeRecord: [Int] = UserDefaults.standard.array(forKey: stage.level.rawValue + String(stage.numberOfStage + 1)) as! Array<Int>
            selfTimeRecord.append(recordTime)
            var newRecord = selfTimeRecord.sorted(by: {$0 < $1})
            if newRecord.count > 5{
                newRecord.removeLast()
            }
            defaults.set(newRecord, forKey: stage.level.rawValue + String(stage.numberOfStage + 1))
        }else{
            defaults.set([recordTime], forKey: stage.level.rawValue + String(stage.numberOfStage + 1))
        }
        defaults.synchronize()
    }
    
    
    @IBAction func nextStage(_ sender: Any){
        self.delegate.touchSound()
        if(stage.numberOfStage > 22){
            delegate.moveViewControllerFromGameOverToGame(stage: stage.nextLevel())
        }else{
            delegate.moveViewControllerFromGameOverToGame(stage: stage.nextStage())
        }

    }
    
    
    @IBAction func checkAnswer(_ sender: Any) {
        self.delegate.touchSound()
        delegate.moveViewControllerFromGameOverToAnswer()

    }
    
    @IBAction func backTitle(_ sender: Any){
        self.delegate.touchSound()
        delegate.moveViewControllerFromGameOverToTitle()
    }
    
    func removeViews(){
        nextStageBtn.isHidden = true
        nextStageBtn.isUserInteractionEnabled = false
        playAgainBtn.isHidden = true
        playAgainBtn.isUserInteractionEnabled = false
        checkAnswerBtn.isHidden = true
        checkAnswerBtn.isUserInteractionEnabled = false
        titleBtn.isHidden = true
        titleBtn.isUserInteractionEnabled = false
        
        resultStamp.removeFromSuperview()
        resultString.removeFromSuperview()
        for view in levelStageLabel.subviews{
            view.removeFromSuperview()
        }
    }
    
    func resultSound(){
        if result{
            self.delegate.successSound()
        }else{
            self.delegate.failureSound()
        }
    }
    
    fileprivate func showBannerView(){
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.frame.origin = CGPoint.init(x: 0, y: referenceSize.height - bannerView.frame.height)
        bannerView.frame.size = CGSize.init(width: bannerView.frame.width, height: bannerView.frame.height)
        bannerView.adUnitID = "ca-app-pub-8719818866106636/8258304101"
        bannerView.delegate = self as GADBannerViewDelegate
        bannerView.rootViewController = self
        let gadRequest:GADRequest = GADRequest()
        bannerView.load(gadRequest)
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

    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        resultProcedureDone = true
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        resultProcedureDone = true
    }
    
    
    
    
    @IBAction func playAgain(_ sender: Any){
        self.delegate.touchSound()
        delegate.moveViewControllerFromGameOverToGame(stage: stage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
