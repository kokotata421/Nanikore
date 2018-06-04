//
//  AnswerViewController.swift
//  Nanikore
//
//  Created by Kota Kawanishi on 2017/04/16.
//  Copyright © 2017年 Kota Kawanishi. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol AnswerViewControllerProtocol{
    func touchSound()
    func moveViewControllerFromAnswerToGame(stage:Stage)
    func moveViewControllerFromAnswerToTitle()
    
}

class AnswerViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate{

    //Views
    @IBOutlet weak var bannerView: GADBannerView!
    var interstitial = GADInterstitial.init(adUnitID: "ca-app-pub-8719818866106636/6627976909")
    var scrollView = UIScrollView()
    var levelStageLabel = UIImageView.init(image: #imageLiteral(resourceName: "LevelStage"))
    var mainBackgroundView = UIImageView.init(image: #imageLiteral(resourceName: "MainBackground"))
    let titleBtn = UIButton.init()
    let selectedBtn = UIButton.init()
    let noteView = UIImageView.init(image: #imageLiteral(resourceName: "AnswerNote"))

    //Data
    var stage: Stage!
    var answers: [[String : String]]!
    var result = false
    var viewSetUpDone = false
    var referenceSize: CGSize!
    
    //Delegate
    var delegate: AnswerViewControllerProtocol!
    
    
    //Scale
    let answerStringLabel = TitleViewController.Scale.init(yScale: 0.1294, widthScale: 0.1288, heightScale: 0.039)
    let minimumContentViewSizeScale: CGFloat = 0.19293
    let answerLabelSizeScaleOf3Characters = TitleViewController.Scale.init(widthScale: 0.32, heightScale: 0.03)
    let answerLabelSizeScaleOf4Characters = TitleViewController.Scale.init(widthScale: 0.38, heightScale: 0.03)
    let answerLabelSizeScaleOf5Characters = TitleViewController.Scale.init(widthScale: 0.47, heightScale: 0.03)
    let answerLabelSizeScaleOf6Characters = TitleViewController.Scale.init(widthScale: 0.48, heightScale: 0.03)
    let answer1XScale: CGFloat = 0.02
    let answer2XScale: CGFloat = 0.51
    let intervalScaleOfAnswers: CGFloat = 0.04
    let intervalScaleOfExtraAnswer: CGFloat = 0.03
    let intervalScaleOfQuestionLabelToAnswer: CGFloat = 0.02
    let levelStageLabelScale = TitleViewController.Scale.init(yScale: 0.0439, widthScale: 0.9742, heightScale: 0.0705)
    let easyStringScale = TitleViewController.Scale.init(xScale: 0.4342, widthScale: 0.2198, heightScale: 0.461)
    let normalStringScale = TitleViewController.Scale.init(xScale: 0.44895, widthScale: 0.1771, heightScale: 0.461)
    let hardStringScale = TitleViewController.Scale.init(xScale: 0.4296, widthScale: 0.2334, heightScale: 0.461)
    let numberSizeScale = TitleViewController.Scale.init(widthScale: 0.0346, heightScale: 0.451)
    let number1SizeScale = TitleViewController.Scale.init(widthScale: 0.0185, heightScale: 0.451)
    let numberXScale: [CGFloat] = [0.9343, 0.89015]
    let additionOfNumber1XScale: CGFloat = 0.00305
    let questionScale = TitleViewController.Scale.init(xScale: 0.02, yScale: 0.1923, widthScale: 0.0532, heightScale: 0.03)
    let questionNumberSizeScale = TitleViewController.Scale.init(widthScale: 0.0305, heightScale: 0.03)
    let questionNumber1SizeScale = TitleViewController.Scale.init(widthScale: 0.02088, heightScale: 0.03)
    let questionNumber10SizeScale = TitleViewController.Scale.init(widthScale: 0.04986, heightScale: 0.03)
    let intervalLengthScaleOfQuestionToNumber:CGFloat = 0.012
    let additionOfQuestionNumber1XScale: CGFloat = 0.00481
    let substractionOfQuestionNumber10XScale: CGFloat = 0.00968
    let btnScale = TitleViewController.Scale.init(yScale:0.79, widthScale: 0.3421, heightScale: 0.0708)
    let noteScale = TitleViewController.Scale.init(xScale: 0.035, yScale: 0.1329, widthScale: 0.6995, heightScale: 0.01953)
    let labelSizeIn3:CGFloat = 16.5
    let labelSizeIn5:CGFloat = 15.5
    let labelSizeIn6:CGFloat = 14
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.referenceSize = self.view.frame.size
        self.delegate = self.parent! as! AnswerViewControllerProtocol
        self.interstialLoad()
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        } else {
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !viewSetUpDone{
            scrollView.contentOffset = CGPoint.init(x: 0, y: -scrollView.contentInset.top)
            self.showBannerView()
            self.showInterstial()
            self.configureAnswerView()
            self.viewSetUpDone = true
        }
        viewSetUpDone = false
    }
    
    func configureAnswerView(){
        let numberOfAnswers = answers.count
        var numberOfExtraHeight = 0
        for i in 0..<answers.count{
            if(answers[i].keys.count > 2){
                numberOfExtraHeight += (answers[i].keys.count - 1) / 2
            }
        }
        
        let eachAnswerHeight = referenceSize.height * intervalScaleOfAnswers + referenceSize.height * intervalScaleOfQuestionLabelToAnswer + referenceSize.height * answerLabelSizeScaleOf3Characters.heightScale + referenceSize.height * questionScale.heightScale
        let eachExtraHeight = referenceSize.height * intervalScaleOfExtraAnswer + referenceSize.height * answerLabelSizeScaleOf3Characters.heightScale
        
        let contentSize = referenceSize.height * minimumContentViewSizeScale + eachAnswerHeight * CGFloat(numberOfAnswers) + eachExtraHeight * CGFloat(numberOfExtraHeight) + referenceSize.height * btnScale.heightScale + referenceSize.height * intervalScaleOfAnswers
        scrollView.contentSize = CGSize.init(width: referenceSize.width, height: referenceSize.height - bannerView.frame.height > contentSize ? referenceSize.height - bannerView.frame.height : contentSize)
        scrollView.frame = CGRect.init(x: 0, y: 0, width: referenceSize.width, height: referenceSize.height - bannerView.frame.height)
        scrollView.bounces = false
        
        mainBackgroundView.frame = CGRect.init(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(mainBackgroundView)
        self.noteView.frame = CGRect.init(x: referenceSize.width * noteScale.xScale, y: referenceSize.height * noteScale.yScale, width: referenceSize.width * noteScale.widthScale, height: referenceSize.height * noteScale.heightScale)
        self.scrollView.addSubview(noteView)
        
        self.showLevelStageLabel()
        self.showAnswerLabels()
    }
    
    func showLevelStageLabel(){
        
        let levelStageLabelSize = CGSize.init(width: referenceSize.width * levelStageLabelScale.widthScale, height: referenceSize.height * levelStageLabelScale.heightScale)
        levelStageLabel.frame = CGRect.init(x: referenceSize.width / 2.0 - levelStageLabelSize.width / 2.0, y: referenceSize.height * levelStageLabelScale.yScale, width: levelStageLabelSize.width, height: levelStageLabelSize.height)
        
        self.scrollView.addSubview(levelStageLabel)
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
            let hardStringSize = CGSize.init(width: levelStageLabelSize.width * hardStringScale.widthScale, height: levelStageLabelSize.height * hardStringScale.heightScale)
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
                let stageNumberViewSize = CGSize.init(width: levelStageLabel.frame.width * numberSizeScale.widthScale, height: levelStageLabel.frame.height * numberSizeScale.heightScale)
                stageNumberViewFrame = CGRect(x: levelStageLabel.frame.width * numberXScale[i], y: levelStageLabel.bounds.midY - stageNumberViewSize.height / 2.0, width: stageNumberViewSize.width, height: stageNumberViewSize.height)
            }
            let stageNumberView = UIImageView.init(frame: stageNumberViewFrame)
            stageNumberView.image = stageNumberImage
            levelStageLabel.addSubview(stageNumberView)
            tempNumber /= 10
        }
        
    }
    
    func showAnswerLabels(){
        var charactersCount = 0
        if  answers.first?.keys.first?.count != nil{
            charactersCount = (answers.first?.keys.first?.count)!
        }
        let intervalLengthOfQuestionLabelToAnswer = referenceSize.height * intervalScaleOfQuestionLabelToAnswer
        let intervalLengthOfAnswers = referenceSize.height * intervalScaleOfAnswers
        var currentYPoint = referenceSize.height * questionScale.yScale
        var answerLabelHeight : CGFloat = 0.0
        for i in 0..<answers.count{
            let questionLabel = UIImageView.init(image: #imageLiteral(resourceName: "QuestionStringLabel"))
            questionLabel.frame = CGRect.init(x: referenceSize.width * questionScale.xScale, y: currentYPoint, width: referenceSize.width * questionScale.widthScale, height: referenceSize.height * questionScale.heightScale)
            self.scrollView.addSubview(questionLabel)
            self.showQuestionNumberLabel(number: i + 1, questionLabel: questionLabel)
            currentYPoint += questionLabel.frame.height + intervalLengthOfQuestionLabelToAnswer
            var count = 1
            let answer = answers[i]
            for (key, value) in answer{
                if count % 2 == 1 && count > 2{
                    currentYPoint += referenceSize.height * answerLabelSizeScaleOf3Characters.heightScale + referenceSize.height * intervalScaleOfExtraAnswer
                }
                let answerLabel = UILabel.init()
                switch charactersCount {
                case 3: answerLabel.frame = CGRect.init(x: count % 2 == 1 ? referenceSize.width * answer1XScale : referenceSize.width * answer2XScale, y: currentYPoint, width: referenceSize.width * answerLabelSizeScaleOf3Characters.widthScale, height: referenceSize.height * answerLabelSizeScaleOf3Characters.heightScale)
                answerLabel.font = UIFont.init(name: "Arial-BoldMT", size: labelSizeIn3)
                case 4: answerLabel.frame = CGRect.init(x: count % 2 == 1 ? referenceSize.width * answer1XScale : referenceSize.width * answer2XScale, y: currentYPoint, width: referenceSize.width * answerLabelSizeScaleOf4Characters.widthScale, height: referenceSize.height * answerLabelSizeScaleOf4Characters.heightScale)
                    answerLabel.font = UIFont.init(name: "Arial-BoldMT", size: labelSizeIn3)
                case 5: answerLabel.frame = CGRect.init(x: count % 2 == 1 ? referenceSize.width * answer1XScale : referenceSize.width * answer2XScale, y: currentYPoint, width: referenceSize.width * answerLabelSizeScaleOf5Characters.widthScale, height: referenceSize.height * answerLabelSizeScaleOf5Characters.heightScale)
                    answerLabel.font = UIFont.init(name: "Arial-BoldMT", size: labelSizeIn5)
                case 6: answerLabel.frame = CGRect.init(x: count % 2 == 1 ? referenceSize.width * answer1XScale : referenceSize.width * answer2XScale, y: currentYPoint, width: referenceSize.width * answerLabelSizeScaleOf6Characters.widthScale, height: referenceSize.height * answerLabelSizeScaleOf6Characters.heightScale)
                    answerLabel.font = UIFont.init(name: "Arial-BoldMT", size: labelSizeIn6)

                default: break
                }
                answerLabelHeight = answerLabel.frame.height
                answerLabel.text = "\(key):\(value)"
                answerLabel.textAlignment = NSTextAlignment.left
                self.scrollView.addSubview(answerLabel)
                
                count += 1
            }
            
            currentYPoint += answerLabelHeight + intervalLengthOfAnswers
        }
        showBtns(y: currentYPoint)
    }
    
    func showBtns(y:CGFloat){
        let btnSize = CGSize.init(width: referenceSize.width * btnScale.widthScale, height: referenceSize.height * btnScale.heightScale)
        selectedBtn.frame = CGRect.init(x: referenceSize.width / 4.0 - btnSize.width / 2.0, y: scrollView.contentSize.height > referenceSize.height - bannerView.frame.height ? y : referenceSize.height * btnScale.yScale, width: btnSize.width, height: btnSize.height)
        if(result && (stage.level != GameLevelSelectViewController.Level.Hard || stage.numberOfStage < 23)){
            selectedBtn.setImage(#imageLiteral(resourceName: "NextStageBtn"), for: UIControlState.normal)
            selectedBtn.addTarget(self, action: #selector(nextStage), for: UIControlEvents.touchUpInside)
        }else{
            selectedBtn.setImage(#imageLiteral(resourceName: "PlayAgainBtn"), for: UIControlState.normal)
            selectedBtn.addTarget(self, action: #selector(playAgain), for: UIControlEvents.touchUpInside)
        }
        titleBtn.frame = CGRect.init(x: referenceSize.width / 2.0 + (referenceSize.width / 2.0 - btnSize.width) / 2.0, y: scrollView.contentSize.height > referenceSize.height - bannerView.frame.height ? y : referenceSize.height * btnScale.yScale, width: btnSize.width, height: btnSize.height)
        titleBtn.setImage(#imageLiteral(resourceName: "TitleBtn"), for: UIControlState.normal)
        titleBtn.addTarget(self, action: #selector(backTitle), for: UIControlEvents.touchUpInside)
        self.scrollView.addSubview(selectedBtn)
        self.scrollView.addSubview(titleBtn)
    }
    
    
    
    @objc func nextStage(){
        self.delegate.touchSound()
        if(stage.numberOfStage > 22){
            self.delegate.moveViewControllerFromAnswerToGame(stage: stage.nextLevel())
        }else{
            self.delegate.moveViewControllerFromAnswerToGame(stage: stage.nextStage())
        }
    }
    
    @objc func playAgain(){
        self.delegate.touchSound()
        self.delegate.moveViewControllerFromAnswerToGame(stage: stage)
    }
    
    @objc func backTitle(){
        self.delegate.touchSound()
        self.delegate.moveViewControllerFromAnswerToTitle()
    }
    func showQuestionNumberLabel(number: Int, questionLabel:UIImageView){
        var numberImageString: String!
        var numberViewFrame: CGRect!
        
        numberImageString = String.init(format: "QuestionNumber%d", number)
        
        if(number == 1){
            let numberViewSize = CGSize.init(width: referenceSize.width * questionNumber1SizeScale.widthScale, height: referenceSize.height * questionNumber1SizeScale.heightScale)
            numberViewFrame = CGRect(x: questionLabel.frame.maxX + referenceSize.width * (intervalLengthScaleOfQuestionToNumber + additionOfQuestionNumber1XScale), y: questionLabel.frame.minY, width: numberViewSize.width, height: numberViewSize.height)
        }else if number == 10{
            let numberViewSize = CGSize.init(width: referenceSize.width * questionNumber10SizeScale.widthScale, height: referenceSize.height * questionNumber10SizeScale.heightScale)
            numberViewFrame = CGRect(x: questionLabel.frame.maxX + referenceSize.width * (intervalLengthScaleOfQuestionToNumber - substractionOfQuestionNumber10XScale), y: questionLabel.frame.minY, width: numberViewSize.width, height: numberViewSize.height)
        }else{
            let numberViewSize = CGSize.init(width: referenceSize.width * questionNumberSizeScale.widthScale, height: referenceSize.height * questionNumberSizeScale.heightScale)
            numberViewFrame = CGRect(x: questionLabel.frame.maxX + referenceSize.width * intervalLengthScaleOfQuestionToNumber, y: questionLabel.frame.minY, width: numberViewSize.width, height: numberViewSize.height)
        }
        let numberView = UIImageView.init(frame: numberViewFrame)
        numberView.image = UIImage.init(named: numberImageString)
        self.scrollView.addSubview(numberView)
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

    fileprivate func showBannerView(){
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.frame.origin = CGPoint.init(x: 0, y: referenceSize.height - bannerView.frame.height)
        bannerView.frame.size = CGSize.init(width: bannerView.frame.width, height: bannerView.frame.height)
        bannerView.adUnitID = "ca-app-pub-8719818866106636/5151243707"
        bannerView.delegate = self as GADBannerViewDelegate
        bannerView.rootViewController = self
        let gadRequest:GADRequest = GADRequest()
        bannerView.load(gadRequest)
    }
    
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        viewSetUpDone = true
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
