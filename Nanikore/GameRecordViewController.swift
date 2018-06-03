//
//  GameRecordViewController.swift
//  Nanikore
//
//  Created by Kota Kawanishi on 2017/03/24.
//  Copyright © 2017年 Kota Kawanishi. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol GameRecordViewControllerProtocol {
    func touchSound()
    func touchSound2()
    func moveViewControllerFromGameRecordToGame(stage:Stage)
    func moveViewControllerFromGameRecordToGameLevelSelect()
}

class GameRecordViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate {
    
    
    //Views
    @IBOutlet weak var backToStageSelectBtn: UIButton!
    @IBOutlet weak var stageLabel: UIImageView!
    @IBOutlet weak var recordChartView: UIImageView!
    @IBOutlet weak var takeTheExamBtn: UIButton!
    @IBOutlet weak var mainBackgroundView: UIImageView!
    @IBOutlet weak var bannerView: GADBannerView!
    var interstitial: GADInterstitial = GADInterstitial.init(adUnitID: "ca-app-pub-8719818866106636/7390236106")
    
    //Delegate
    var delegate: GameRecordViewControllerProtocol! = nil
    
    
    //Data
    var referenceSize: CGSize!
    var selectedStage: Stage!
    var selfRecord: [Int]!
    var rankRecord: [Int]!
    var viewSetUpDone: Bool = false
    
    
    //Scale
    let stageLabelScale = TitleViewController.Scale.init(yScale: 0.0288, widthScale: 0.6097, heightScale: 0.1054)
    let recordChartViewScale = TitleViewController.Scale.init(yScale: 0.1462, widthScale: 0.8734, heightScale: 0.6308)
    let takeTheExamBtnScale = TitleViewController.Scale.init(yScale: 0.7938, widthScale: 0.5614, heightScale: 0.1003)
    let backStageSelectBtnScale = TitleViewController.Scale.init(xScale: 0.0102, yScale: 0.0288, sizeScale: 0.1739)
    let noRecordLabelScaleToChart = TitleViewController.Scale.init(xScale: 0.5844, widthScale: 0.2009, heightScale: 0.0471)
    let secondLabelScaleToChart = TitleViewController.Scale.init(xScale: 0.7329, widthScale: 0.0524, heightScale: 0.0471)
    let minuteLabelScaleToChart = TitleViewController.Scale.init(xScale: 0.5859, widthScale: 0.0524, heightScale: 0.0471)
    let stageLabelNumber1ScaleToLabel = TitleViewController.Scale.init(widthScale: 0.05061, heightScale: 0.4971)
    let stageLabelNumberScaleToLabel = TitleViewController.Scale.init(widthScale: 0.0736, heightScale: 0.4971)
    let stageNumberXScaleToLabel:[CGFloat] = [0.7916, 0.6925]
    let additionOfXScaleInStageNumber1: CGFloat = 0.00249
    let recordNumberSizeScaleToChart = TitleViewController.Scale.init(widthScale: 0.0321, heightScale: 0.0416)
    let recordNumber1SizeScaleToChart = TitleViewController.Scale.init(widthScale: 0.0208, heightScale: 0.0416)
    let minuteNumberXScaleToChart: CGFloat = 0.5498
    let secondsNumberXScaleToChart: [CGFloat] = [0.6865, 0.6497]
    let additionOfXScaleInRecordNumber1: CGFloat = 0.00565
    let stringLabelYScaleToChart: [CGFloat] = [0.1338, 0.1999, 0.266, 0.3322, 0.3983, 0.6094, 0.6756, 0.7417, 0.8079, 0.874]
    let numberYScaleToChart: [CGFloat] = [0.138, 0.2056, 0.2721, 0.3386, 0.4042, 0.6133, 0.6794, 0.7456, 0.8117, 0.8779]

    //Others
    let kRankOfRecordKey = "rankOfRecord"
    let kStageKey = "stage"
    let kStageRecordKey = "StageRecord"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        referenceSize = self.view.frame.size
        self.delegate = self.parent as! GameRecordViewControllerProtocol
        self.configureViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !viewSetUpDone{
            self.showBannerView()
            self.configureLevelLabelImageViews()
            self.fetchRecord()
            self.showInterstial()
            viewSetUpDone = true
        }
        viewSetUpDone = false
    }

    func configureViews(){
        let mainBackgroundFrame = CGRect.init(x: 0, y: 0, width: referenceSize.width, height: referenceSize.height - bannerView.frame.height)
        let backStageSelectBtnFrame = CGRect(x: referenceSize.width * backStageSelectBtnScale.xScale, y: referenceSize.height * backStageSelectBtnScale.yScale, width: referenceSize.width * backStageSelectBtnScale.widthScale, height:referenceSize.width * backStageSelectBtnScale.widthScale)
        let recordChartSize = CGSize(width: referenceSize.width * recordChartViewScale.widthScale, height: referenceSize.height * recordChartViewScale.heightScale)
        let recordChartFrame = CGRect(x: referenceSize.width / 2.0 - recordChartSize.width / 2.0, y: referenceSize.height * recordChartViewScale.yScale, width: recordChartSize.width, height: recordChartSize.height)
        let stageLabelSize = CGSize(width: referenceSize.width * stageLabelScale.widthScale, height: backStageSelectBtnFrame.height)
        let stageLabelFrame = CGRect(x: referenceSize.width / 2.0 - stageLabelSize.width / 2.0, y: referenceSize.height * stageLabelScale.yScale, width: stageLabelSize.width, height: stageLabelSize.height)
        let takeTheExamBtnSize = CGSize(width: referenceSize.width * takeTheExamBtnScale.widthScale, height: referenceSize.height * takeTheExamBtnScale.heightScale)
        let takeTheExamBtnFrame = CGRect(x: referenceSize.width / 2.0 - takeTheExamBtnSize.width / 2.0, y: referenceSize.height * takeTheExamBtnScale.yScale, width: takeTheExamBtnSize.width, height: takeTheExamBtnSize.height)
        
        mainBackgroundView.frame = mainBackgroundFrame
        backToStageSelectBtn.frame = backStageSelectBtnFrame
        recordChartView.frame = recordChartFrame
        stageLabel.frame = stageLabelFrame
        takeTheExamBtn.frame = takeTheExamBtnFrame
    }
    
    func configureLevelLabelImageViews(){
        switch selectedStage.level {
        case GameLevelSelectViewController.Level.Easy:
            stageLabel.image = #imageLiteral(resourceName: "StageEasyLabel")
        case GameLevelSelectViewController.Level.Normal:
            stageLabel.image = #imageLiteral(resourceName: "StageNormalLabel")
        case GameLevelSelectViewController.Level.Hard:
            stageLabel.image = #imageLiteral(resourceName: "StageHardLabel")
        }
        self.showNumberViewOnLabel()
    }
    
    func showNumberViewOnLabel(){
        var tempNumber = self.selectedStage.numberOfStage + 1
        for i in 0..<2{
            var stageNumberImageString: String!
            var stageNumberImage: UIImage!
            var stageNumberViewFrame: CGRect!
            
            if(i == 1 && self.selectedStage.numberOfStage < 9){
                stageNumberImage = #imageLiteral(resourceName: "StageNumber0")
            }else{
                stageNumberImageString = String.init(format: "StageNumber%d", tempNumber % 10)
                stageNumberImage = UIImage.init(named: stageNumberImageString)
            }
            
            if(tempNumber % 10 == 1){
                stageNumberViewFrame = CGRect(x: self.stageLabel.frame.width * (stageNumberXScaleToLabel[i] + additionOfXScaleInStageNumber1), y: self.stageLabel.frame.height / 2.0 - (self.stageLabel.frame.height * stageLabelNumber1ScaleToLabel.heightScale) / 2.0, width: self.stageLabel.frame.width * stageLabelNumber1ScaleToLabel.widthScale, height: self.stageLabel.frame.height * stageLabelNumber1ScaleToLabel.heightScale)
            }else{
                stageNumberViewFrame = CGRect(x: self.stageLabel.frame.width * stageNumberXScaleToLabel[i], y: self.stageLabel.frame.height / 2.0 - (self.stageLabel.frame.height * stageLabelNumberScaleToLabel.heightScale) / 2.0, width: self.stageLabel.frame.width * stageLabelNumberScaleToLabel.widthScale, height: self.stageLabel.frame.height * stageLabelNumberScaleToLabel.heightScale)
            }
            let stageNumberView = UIImageView.init(frame: stageNumberViewFrame)
            stageNumberView.image = stageNumberImage
            self.stageLabel.addSubview(stageNumberView)
            tempNumber /= 10
        }
    }
    
    
    func fetchRecord() {
        fetchRankRecord()
        fetchSelfRecord()
    }
    
    func fetchSelfRecord(){
        let key = String.init(format: selectedStage.level.rawValue + "%d", selectedStage.numberOfStage + 1)
        if UserDefaults.standard.object(forKey: key) != nil{
            self.selfRecord = UserDefaults.standard.array(forKey: key) as! Array<Int>!
        }else{
            self.selfRecord = nil
        }
        self.showRecordNumber(record: selfRecord, selfRecord: true)
    }
    
    func fetchRankRecord(){
        let query:NCMBQuery = NCMBQuery(className: kStageRecordKey)
        query.whereKey(kStageKey, equalTo: selectedStage.level.rawValue + String(selectedStage.numberOfStage + 1))
        var results:[AnyObject] = []
        do {
            results = try query.findObjects() as [AnyObject]
        } catch  let error1 as NSError  {
            print("\(error1)")
            let alertController = UIAlertController(title: "データ取得失敗", message: "データを取得できませんでした。", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: {
                self.interstialLoad()
            })
        }
        if results.count > 0 {
            let stageRecord: NCMBObject = (results.first as? NCMBObject)!
            self.rankRecord = stageRecord.object(forKey: kRankOfRecordKey) as! [Int]!
            if (self.rankRecord.first != nil){
                if(self.rankRecord.first == 0){
                    self.rankRecord = nil
                }
            }
            self.showRecordNumber(record: rankRecord, selfRecord:false)
        }else{
            let alertController = UIAlertController(title: "データ取得失敗", message: "データを取得できませんでした。", preferredStyle:UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: {
                self.interstialLoad()
            })
            rankRecord = nil
            self.showRecordNumber(record: rankRecord, selfRecord:false)
        }
        
    }
    
    func showRecordNumber(record: [Int]!, selfRecord:Bool){
        let numberYScale = selfRecord ? Array(numberYScaleToChart[0..<5]) : Array(numberYScaleToChart[5..<10])
        let stringYScale = selfRecord ? Array(stringLabelYScaleToChart[0..<5]) : Array(stringLabelYScaleToChart[5..<10])
        
        
        for i in 0..<5{
            if record == nil{
                let noRecordViewFrame = CGRect(x: recordChartView.frame.width * noRecordLabelScaleToChart.xScale, y: recordChartView.frame.height * stringYScale[i], width: recordChartView.frame.width * noRecordLabelScaleToChart.widthScale, height: recordChartView.frame.height * noRecordLabelScaleToChart.heightScale)
                let noRecordView = UIImageView.init(image:#imageLiteral(resourceName: "StageRecordNoRecordLabel"))
                noRecordView.frame = noRecordViewFrame
                self.recordChartView.addSubview(noRecordView)
            }else{
                if i < record.count {
                    let minute = record[i] / 60
                    let second = record[i] % 60
                    if minute != 0{
                        var minuteViewFrame: CGRect!
                        if minute == 1{
                            minuteViewFrame = CGRect(x: recordChartView.frame.width * (minuteNumberXScaleToChart + additionOfXScaleInRecordNumber1), y: recordChartView.frame.height * numberYScale[i], width: recordChartView.frame.width * recordNumber1SizeScaleToChart.widthScale, height: recordChartView.frame.height * recordNumber1SizeScaleToChart.heightScale)
                        }else{
                            minuteViewFrame = CGRect(x: recordChartView.frame.width * minuteNumberXScaleToChart, y: recordChartView.frame.height * numberYScale[i], width: recordChartView.frame.width * recordNumberSizeScaleToChart.widthScale, height: recordChartView.frame.height * recordNumberSizeScaleToChart.heightScale)
                        }
                        let minuteView = UIImageView.init(frame: minuteViewFrame)
                        minuteView.image = UIImage.init(named: String.init(format: "StageRecordNumber%d", minute))
                        self.recordChartView.addSubview(minuteView)
                        
                        let minuteLabelFrame = CGRect(x: recordChartView.frame.width * minuteLabelScaleToChart.xScale, y: recordChartView.frame.height * stringYScale[i], width: recordChartView.frame.width * minuteLabelScaleToChart.widthScale, height: recordChartView.frame.height * minuteLabelScaleToChart.heightScale)
                        let minuteLabelView = UIImageView.init(image:#imageLiteral(resourceName: "StageRecordMinuteLabel"))
                        minuteLabelView.frame = minuteLabelFrame
                        self.recordChartView.addSubview(minuteLabelView)
                    }
                    var tempSecond = second
                    for k in 0..<2{
                        var secondNumberImage: UIImage!
                        var secondNumberViewFrame: CGRect!
                        
                        if(k == 1 && second < 10){
                            secondNumberImage = #imageLiteral(resourceName: "StageRecordNumber0")
                        }else{
                            secondNumberImage = UIImage.init(named: String.init(format: "StageRecordNumber%d", tempSecond % 10))
                        }
                        if(tempSecond % 10 == 1){
                            secondNumberViewFrame = CGRect(x: recordChartView.frame.width * (secondsNumberXScaleToChart[k] + additionOfXScaleInRecordNumber1), y: recordChartView.frame.height * numberYScale[i], width: recordChartView.frame.width * recordNumber1SizeScaleToChart.widthScale, height: recordChartView.frame.height * recordNumber1SizeScaleToChart.heightScale)
                        }else{
                            secondNumberViewFrame = CGRect(x: recordChartView.frame.width * secondsNumberXScaleToChart[k], y: recordChartView.frame.height * numberYScale[i], width: recordChartView.frame.width * recordNumberSizeScaleToChart.widthScale, height: recordChartView.frame.height * recordNumberSizeScaleToChart.heightScale)
                        }
                        let secondNumberView = UIImageView.init(frame: secondNumberViewFrame)
                        secondNumberView.image = secondNumberImage
                        recordChartView.addSubview(secondNumberView)
                        tempSecond /= 10
                    }
                    let secondLabelFrame = CGRect(x: recordChartView.frame.width * secondLabelScaleToChart.xScale, y: recordChartView.frame.height * stringYScale[i], width: recordChartView.frame.width * secondLabelScaleToChart.widthScale, height: recordChartView.frame.height * secondLabelScaleToChart.heightScale)
                    let secondLabelView = UIImageView.init(image:#imageLiteral(resourceName: "StageRecordSecondLabel"))
                    secondLabelView.frame = secondLabelFrame
                    self.recordChartView.addSubview(secondLabelView)

                }else{
                    
                    let noRecordViewFrame = CGRect(x: recordChartView.frame.width * noRecordLabelScaleToChart.xScale, y: recordChartView.frame.height * stringYScale[i], width: recordChartView.frame.width * noRecordLabelScaleToChart.widthScale, height: recordChartView.frame.height * noRecordLabelScaleToChart.heightScale)
                    let noRecordView = UIImageView.init(image:#imageLiteral(resourceName: "StageRecordNoRecordLabel"))
                    noRecordView.frame = noRecordViewFrame
                    self.recordChartView.addSubview(noRecordView)
                }
            }
        }
    }
    
    fileprivate func showBannerView(){
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.frame.origin = CGPoint.init(x: 0, y: referenceSize.height - bannerView.frame.height)
        bannerView.frame.size = CGSize.init(width: bannerView.frame.width, height: bannerView.frame.height)
        bannerView.adUnitID = "ca-app-pub-8719818866106636/2977689705"
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
        viewSetUpDone = true
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        viewSetUpDone = true
    }
    
    
    @IBAction func takeAnExam(_ sender: Any) {
        self.delegate.touchSound()
        for view in self.stageLabel.subviews{
            view.removeFromSuperview()
        }
        for view in self.recordChartView.subviews{
            view.removeFromSuperview()
        }
        self.delegate.moveViewControllerFromGameRecordToGame(stage: selectedStage)
    }
    
    @IBAction func backSelectStage(_ sender: Any) {
        self.delegate.touchSound2()
        for view in self.stageLabel.subviews{
            view.removeFromSuperview()
        }
        for view in self.recordChartView.subviews{
            view.removeFromSuperview()
        }
        self.delegate.moveViewControllerFromGameRecordToGameLevelSelect()
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
