//
//  GameViewController.swift
//  Nanikore
//
//  Created by Kota Kawanishi on 2017/03/05.
//  Copyright © 2017年 Kota Kawanishi. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol GameViewControllerProtocol {
    func moveViewControllerFromGameToGameOver(result:Bool, stage:Stage)
    func playBGM()
    func turnBGMDown()
    func isSoundOn()->Bool
}



extension UIScrollView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isScrollEnabled = false
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isScrollEnabled = true
    }
}

class GameViewController: UIViewController, QuestionProtocol, CharacterViewProtocol {
    
    //Views
    
    
    var scrollView = UIScrollView()
    var timeLeftFrameView = UIImageView.init(image: #imageLiteral(resourceName: "TimeLeftView"))
    var levelStageLabel = UIImageView.init(image: #imageLiteral(resourceName: "LevelStage"))
    var mainBackgroundView = UIImageView.init(image: #imageLiteral(resourceName: "MainBackground"))
    var questionLabelViews = Array<UIImageView>.init();
    var minViews = [UIImageView]()
    var secViews = [UIImageView]()
    var noteView = UIImageView.init(image: #imageLiteral(resourceName: "GameNote"))
    var countDownNumberView = UIImageView.init()
    
    //Data
    var stage: Stage!
    var soundIdRing:SystemSoundID = 0
    var referenceSize: CGSize!
    var numberOfQuestions: Int!
    var questions = [Question]()
    var timeLeft: Int!
    var timer: Timer!
    var heightsOfQuestion: [CGFloat] = Array()
    
    //Delegate
    var delegate: GameViewControllerProtocol! = nil

    
    //Scale
    let levelStageLabelScale = TitleViewController.Scale.init(yScale: 0.0439, widthScale: 0.9742, heightScale: 0.0705)
    let easyStringScale = TitleViewController.Scale.init(xScale: 0.4342, widthScale: 0.2198, heightScale: 0.461)
    let normalStringScale = TitleViewController.Scale.init(xScale: 0.44895, widthScale: 0.1771, heightScale: 0.461)
    let hardStringScale = TitleViewController.Scale.init(xScale: 0.4296, widthScale: 0.2334, heightScale: 0.461)
    let numberSizeScale = TitleViewController.Scale.init(widthScale: 0.0346, heightScale: 0.451)
    let number1SizeScale = TitleViewController.Scale.init(widthScale: 0.0185, heightScale: 0.451)
    let numberXScale: [CGFloat] = [0.9343, 0.89015]
    let additionOfNumber1XScale: CGFloat = 0.00305
    let questionScale = TitleViewController.Scale.init(xScale: 0.035, yScale: 0.2, widthScale: 0.0562, heightScale: 0.0326)
    let intervalScaleOfQuestionAndSquare: CGFloat = 0.0241
    let intervalScaleOfQuestions: CGFloat = 0.0402
    let intervalScaleOfBtns: CGFloat = 0.0141
    let intervalLengthOfCharacterScale: CGFloat = 0.01
    let squareScale = TitleViewController.Scale.init(xScale: 0.035, sizeScale: 0.19)
    let squareScaleIn5 = TitleViewController.Scale.init(xScale: 0.035, sizeScale: 0.17)
    let squareScaleIn6 = TitleViewController.Scale.init(xScale: 0.035, sizeScale: 0.143)
    let answerBtnScale = TitleViewController.Scale.init(xScale: 0.8259, widthScale: 0.171, heightScale: 0.0637)
    let timeFrameSizeScale = TitleViewController.Scale.init(widthScale: 1.0, heightScale: 0.0952)
    let colonScaleToFrame = TitleViewController.Scale.init(yScale: 0.493, widthScale: 0.0161, heightScale: 0.332)
    let timeNumberScaleToFrame = TitleViewController.Scale.init(yScale: 0.435, widthScale: 0.0458, heightScale: 0.439)
    let timeNumber1ScaleToFrame = TitleViewController.Scale.init(yScale: 0.435, widthScale: 0.0305, heightScale: 0.439)
    let additionOfTimeNumber1XScale: CGFloat = 0.0053
    let minuteNumberXScale: [CGFloat] = [0.4169, 0.3599]
    let secondNumberXScale: [CGFloat] = [0.5892, 0.5322]
    let questionNumberSizeScale = TitleViewController.Scale.init(widthScale: 0.0325, heightScale: 0.0326)
    let questionNumber1SizeScale = TitleViewController.Scale.init(widthScale: 0.02288, heightScale: 0.0326)
    let questionNumber10SizeScale = TitleViewController.Scale.init(widthScale: 0.05186, heightScale: 0.0326)
    let intervalLengthScaleOfQuestionToNumber:CGFloat = 0.012
    let additionOfQuestionNumber1XScale: CGFloat = 0.00481
    let substractionOfQuestionNumber10XScale: CGFloat = 0.00568
    let countDownScale = TitleViewController.Scale.init(yScale: 0.2402, widthScale: 0.5233, heightScale: 0.0488)
    let gameStartCountNumberScale = TitleViewController.Scale.init(xScale: 0.41079, yScale: 0.318, widthScale: 0.0523, heightScale: 0.04296)
    let gameStartCountNumber1Scale = TitleViewController.Scale.init(xScale: 0.41069, yScale: 0.318, widthScale: 0.0289, heightScale: 0.04296)
    let gameStartCountSecondLabelScale = TitleViewController.Scale.init(xScale: 0.4906, yScale: 0.3157, widthScale: 0.08132, heightScale: 0.04833)
    let correctCircleScale = TitleViewController.Scale.init(xScale: -0.0229, yScale: -0.0201, widthScale: 0.1288, heightScale: 0.0717)
    let incorrectCircleScale = TitleViewController.Scale.init(xScale: 0.0129, yScale: -0.0201, widthScale: 0.1288, heightScale: 0.0667)
    let noteScale = TitleViewController.Scale.init(xScale: 0.035, yScale: 0.1329, widthScale: 0.4855, heightScale: 0.01953)
    let noteScaleOfSixCharacters = TitleViewController.Scale.init(xScale: 0.035, yScale: 0.165, widthScale: 0.7536, heightScale: 0.01953)

    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        referenceSize = self.view.frame.size
        self.delegate = self.parent! as! GameViewControllerProtocol
        scrollView.bounces = false
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        } else {
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.addObserver()
        numberOfQuestions = stage.numberOfQuestion
        timeLeft = stage.time
        
        scrollView.contentSize = CGSize.init(width: referenceSize.width, height: referenceSize.height - timeLeftFrameView.frame.height)
        heightsOfQuestion.removeAll()
        
        self.delegate.playBGM()
        self.delegate.turnBGMDown()
        self.fetchQuestionDate()
        self.gameStartCount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gameStartCount(){
        self.configureTimeFrame()
        countDownNumberView = UIImageView.init(image: #imageLiteral(resourceName: "GameStartCountNumber5"))
        var countDownTime = 5
        scrollView.frame = CGRect.init(x: 0, y: 0, width: referenceSize.width, height: referenceSize.height - timeLeftFrameView.frame.height)
        mainBackgroundView.frame = CGRect.init(x: 0, y: 0, width: referenceSize.width, height: referenceSize.height - timeLeftFrameView.frame.height)
        
        let countDownSize = CGSize.init(width: referenceSize.width * countDownScale.widthScale, height: referenceSize.height * countDownScale.heightScale)
        let countDownLabel = UIImageView.init(frame: CGRect.init(x: referenceSize.width / 2.0 - countDownSize.width / 2.0, y: referenceSize.height * countDownScale.yScale, width: countDownSize.width, height: countDownSize.height))
        countDownLabel.image = #imageLiteral(resourceName: "UntilTimeOfGameStartLabel")
        let countDownSecondLabel = UIImageView.init(frame: CGRect.init(x: referenceSize.width * gameStartCountSecondLabelScale.xScale, y: referenceSize.height * gameStartCountSecondLabelScale.yScale, width: referenceSize.width * gameStartCountSecondLabelScale.widthScale, height: referenceSize.height * gameStartCountSecondLabelScale.heightScale))
        countDownSecondLabel.image = #imageLiteral(resourceName: "GameStartCountSecondLabel")
        countDownNumberView.frame = CGRect.init(x: referenceSize.width * gameStartCountNumberScale.xScale, y: referenceSize.height * gameStartCountNumberScale.yScale, width: referenceSize.width * gameStartCountNumberScale.widthScale, height: referenceSize.height * gameStartCountNumberScale.heightScale)
        disableScroll()
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(mainBackgroundView)
        self.scrollView.addSubview(countDownLabel)
        self.scrollView.addSubview(countDownNumberView)
        self.scrollView.addSubview(countDownSecondLabel)
        self.showLevelStageLabel()
        
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {(timer: Timer) in
            
            UIView.animate(withDuration: 0.9, animations: { ()->Void in self.countDownNumberView.alpha = 0.0}, completion: {(Bool)-> Void in
                countDownTime -= 1
                self.showCountDownNumber(count: countDownTime)
                if(countDownTime > 0){
                    self.countDownNumberView.alpha = 1.0
                    
                }
                
            })
                
            if countDownTime < 1{
                self.countDownFinishSound()
                self.timer.invalidate()
                self.timer = nil
                countDownLabel.removeFromSuperview()
                self.countDownNumberView.removeFromSuperview()
                countDownSecondLabel.removeFromSuperview()
                self.gameStart()
                self.enableScroll()
            }else{
                self.countDownSound()
            }

        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes)
        }
        
    }
    
    func showCountDownNumber(count:Int){
        
        if count == 1{
            countDownNumberView.frame = CGRect.init(x: self.referenceSize.width * self.gameStartCountNumber1Scale.xScale, y: self.referenceSize.height * self.gameStartCountNumber1Scale.yScale, width: self.referenceSize.width * self.gameStartCountNumber1Scale.widthScale, height: self.referenceSize.height * self.gameStartCountNumber1Scale.heightScale)
        }
        self.countDownNumberView.image = UIImage.init(named: "GameStartCountNumber\(count)")
        
    }
    
    func gameStart(){
        self.configureGameView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {self.startTimer(time: self.timeLeft)})
    }
    
    func configureGameView(){
        
        var squareHeight:CGFloat!
        
        switch (self.questions.first?.info.difficultyOfQuestion)! {
        case 3...4:
            squareHeight = referenceSize.width * squareScale.widthScale
        case 5:
            squareHeight = referenceSize.width * (squareScaleIn5.widthScale)
        case 6:
            squareHeight = referenceSize.width * (squareScaleIn6.widthScale)
        default:
            break
        }
        let eachQuestionHeight = referenceSize.height * intervalScaleOfQuestions + referenceSize.height * intervalScaleOfQuestionAndSquare * 3 + squareHeight * 2 + referenceSize.height * questionScale.heightScale + referenceSize.height * answerBtnScale.heightScale
        let contentSize = referenceSize.height * questionScale.yScale + eachQuestionHeight * CGFloat(numberOfQuestions)
        if (questions.first?.info.difficultyOfQuestion!)! < 6{
            scrollView.contentSize = CGSize.init(width: referenceSize.width, height: referenceSize.height - timeLeftFrameView.frame.height > contentSize ? referenceSize.height - timeLeftFrameView.frame.height : contentSize)
        }else{
            let contentWidth = referenceSize.width * squareScale.xScale + referenceSize.width * (squareScale.widthScale - 0.05) * CGFloat((questions.first?.info.difficultyOfQuestion!)!) + referenceSize.height * intervalLengthOfCharacterScale * 6
            scrollView.contentSize = CGSize.init(width: referenceSize.width > contentWidth ? referenceSize.width : contentWidth, height: referenceSize.height - timeLeftFrameView.frame.height > contentSize ? referenceSize.height - timeLeftFrameView.frame.height : contentSize)
            if contentWidth > referenceSize.width{
                let noteViewOf6Characters = UIImageView.init(image: #imageLiteral(resourceName: "GameNoteOfSixCharacters"))
                noteViewOf6Characters.frame = CGRect.init(x: referenceSize.width * noteScaleOfSixCharacters.xScale, y: referenceSize.height * noteScaleOfSixCharacters.yScale, width: referenceSize.width * noteScaleOfSixCharacters.widthScale, height: referenceSize.height * noteScaleOfSixCharacters.heightScale)
                self.scrollView.addSubview(noteViewOf6Characters)
                
            }
        }
        mainBackgroundView.frame = CGRect.init(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        self.noteView.frame = CGRect.init(x: referenceSize.width * noteScale.xScale, y: referenceSize.height * noteScale.yScale, width: referenceSize.width * noteScale.widthScale, height: referenceSize.height * noteScale.heightScale)
        self.scrollView.addSubview(noteView)
        self.showQuestionViews()
    }
    
    
    func configureTimeFrame(){
        timeLeftFrameView.frame = CGRect.init(x: 0, y: referenceSize.height - referenceSize.height * timeFrameSizeScale.heightScale, width: referenceSize.width, height: referenceSize.height * timeFrameSizeScale.heightScale)
        let timeColonSize = CGSize.init(width: timeLeftFrameView.frame.width * colonScaleToFrame.widthScale, height: timeLeftFrameView.frame.height * colonScaleToFrame.heightScale)
        let timeColonView = UIImageView.init(frame: CGRect.init(x: timeLeftFrameView.frame.width / 2.0 - timeColonSize.width / 2.0, y: timeLeftFrameView.frame.height * colonScaleToFrame.yScale, width: timeColonSize.width, height: timeColonSize.height))
        timeColonView.image = #imageLiteral(resourceName: "TimeLeftColon")
        
        timeLeftFrameView.layer.borderColor = UIColor.black.cgColor
        timeLeftFrameView.layer.borderWidth = 1.0
        timeLeftFrameView.addSubview(timeColonView)
        self.view.addSubview(timeLeftFrameView)
        self.showTimeCount(beginning: true)
    }
    
    func startTimer(time: Int!){
        if self.timer != nil && self.timer.isValid{
            return
        }
    
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {(timer: Timer) in
            self.timeLeft = self.timeLeft - 1
            if self.timeLeft < 1{
                for question in self.questions{
                    question.answerBtn.isUserInteractionEnabled = false
                    question.resetBtn.isUserInteractionEnabled = false
                    question.delegate = nil
                }
                self.timer.invalidate()
                self.timer = nil
                self.countDownFinishSound()
                self.gameOver(result: false)
            }
            
            if self.timeLeft < 11 || self.timeLeft == 30 || self.timeLeft == 20 || self.timeLeft == 60{
                self.countDownSound()
            }
            self.showTimeCount(beginning: false)
        })
        
        RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes)
    }
    
    func showTimeCount(beginning: Bool){
        var m = timeLeft / 60
        var s = timeLeft % 60
        
        if !secViews.isEmpty{
            for i in 0..<2{
                secViews[i].removeFromSuperview()
            }
            secViews.removeAll()
        }
        
        if s == 59 || beginning{
            if !minViews.isEmpty{
                for i in 0..<2{
                    minViews[i].removeFromSuperview()
                }
                minViews.removeAll()
            }
    
            
            for i in 0..<2{
                let tm = m % 10
                
                let mNumberView = UIImageView.init(image: UIImage.init(named: "TimeLeftNumber\(tm)"))
                
                if tm == 1{
                    mNumberView.frame = CGRect.init(x: timeLeftFrameView.frame.width * (minuteNumberXScale[i] + additionOfTimeNumber1XScale), y: timeLeftFrameView.frame.height * timeNumber1ScaleToFrame.yScale, width: timeLeftFrameView.frame.width * timeNumber1ScaleToFrame.widthScale, height: timeLeftFrameView.frame.height * timeNumber1ScaleToFrame.heightScale)
                }else{
                    mNumberView.frame = CGRect.init(x: timeLeftFrameView.frame.width * minuteNumberXScale[i], y: timeLeftFrameView.frame.height * timeNumberScaleToFrame.yScale, width: timeLeftFrameView.frame.width * timeNumberScaleToFrame.widthScale, height: timeLeftFrameView.frame.height *  timeNumberScaleToFrame.heightScale)
                }
                minViews.append(mNumberView)
                timeLeftFrameView.addSubview(mNumberView)
                m /= 10
            }
        }

        
        for i in 0..<2{
            let ts = s % 10
            
            let sNumberView = UIImageView.init(image: UIImage.init(named: "TimeLeftNumber\(ts)"))
            if ts == 1{
                sNumberView.frame = CGRect.init(x: timeLeftFrameView.frame.width * (secondNumberXScale[i] + additionOfTimeNumber1XScale), y: timeLeftFrameView.frame.height * timeNumber1ScaleToFrame.yScale, width: timeLeftFrameView.frame.width * timeNumber1ScaleToFrame.widthScale, height: timeLeftFrameView.frame.height * timeNumber1ScaleToFrame.heightScale)
            }else{
                sNumberView.frame = CGRect.init(x: timeLeftFrameView.frame.width * secondNumberXScale[i], y: timeLeftFrameView.frame.height * timeNumberScaleToFrame.yScale, width: timeLeftFrameView.frame.width * timeNumberScaleToFrame.widthScale, height: timeLeftFrameView.frame.height * timeNumberScaleToFrame.heightScale)
            }
            secViews.append(sNumberView)
            timeLeftFrameView.addSubview(sNumberView)
            s /= 10
        }
    }

    
    func showLevelStageLabel(){
        
        let levelStageLabelSize = CGSize.init(width: referenceSize.width * levelStageLabelScale.widthScale, height: referenceSize.height * levelStageLabelScale.heightScale)
        levelStageLabel.frame = CGRect.init(x: referenceSize.width / 2.0 - levelStageLabelSize.width / 2.0, y: referenceSize.height * levelStageLabelScale.yScale, width: levelStageLabelSize.width, height: levelStageLabelSize.height)
        
        
        self.scrollView.addSubview(levelStageLabel)
        view.bringSubview(toFront: levelStageLabel)
        
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
                let stageNumberViewSize = CGSize.init(width: levelStageLabel.frame.width * numberSizeScale.widthScale, height: levelStageLabel.frame.height * numberSizeScale.heightScale)
                stageNumberViewFrame = CGRect(x: levelStageLabel.frame.width * numberXScale[i], y: levelStageLabel.bounds.midY - stageNumberViewSize.height / 2.0, width: stageNumberViewSize.width, height: stageNumberViewSize.height)
            }
            let stageNumberView = UIImageView.init(frame: stageNumberViewFrame)
            stageNumberView.image = stageNumberImage
            levelStageLabel.addSubview(stageNumberView)
            tempNumber /= 10
        }
    }
    
    func showQuestionViews(){
        let intervalLengthOfQuestionAndSquare = referenceSize.height * intervalScaleOfQuestionAndSquare
        let intervalLengthOfQuesitons = referenceSize.height * intervalScaleOfQuestions
        let intervalLengthOfCharacters = referenceSize.height * intervalLengthOfCharacterScale
        let intervalLengthOfBtns = referenceSize.height * intervalScaleOfBtns
        var currentYPoint = referenceSize.height * questionScale.yScale
        for i in 0..<numberOfQuestions{
            let questionLabel = UIImageView.init(image: #imageLiteral(resourceName: "QuestionStringLabel"))
            questionLabel.frame = CGRect.init(x: referenceSize.width * questionScale.xScale, y: currentYPoint, width: referenceSize.width * questionScale.widthScale, height: referenceSize.height * questionScale.heightScale)
            heightsOfQuestion.append(currentYPoint)
            self.scrollView.addSubview(questionLabel)
            self.questionLabelViews.append(questionLabel)
            setQuestionNumberLabel(number: i + 1, questionLabel: questionLabel)
            currentYPoint += intervalLengthOfQuestionAndSquare + questionLabel.frame.height
            var characterArray = Array(questions[i].info.shuffleWord())
            let btnSize = CGSize.init(width: referenceSize.width * answerBtnScale.widthScale, height: referenceSize.height * answerBtnScale.heightScale)
            var squareSize: CGFloat!
            
            switch (self.questions.first?.info.difficultyOfQuestion)! {
            case 3...4:
                squareSize = referenceSize.width * squareScale.widthScale
            case 5:
                squareSize = referenceSize.width * squareScaleIn5.widthScale
            case 6:
                squareSize = referenceSize.width * squareScaleIn6.widthScale
            default:
                break
            }
            
            for j in 0..<2{
                var currentXPoint = referenceSize.width * squareScale.xScale
                for k in 0..<questions[i].info.difficultyOfQuestion{
                    
                    if j == 0{
                        let square = BlankSquareView.init(frame: CGRect.init(x: currentXPoint, y: currentYPoint, width: squareSize, height: squareSize))
                        self.scrollView.addSubview(square)
                        questions[i].squareViews.append(square)
                    }else{
                        let characterView = CharacterView.init(character: characterArray[k], gameViewController: self, question: questions[i], frame: CGRect.init(x: currentXPoint, y: currentYPoint, width: squareSize, height: squareSize))
                        self.scrollView.addSubview(characterView)
                        questions[i].characterViews.append(characterView)
                    }
                    
                    
                    currentXPoint += squareSize + intervalLengthOfCharacters
                }
                
                currentYPoint += squareSize + intervalLengthOfQuestionAndSquare
                
            }
            questions[i].answerBtn.frame = CGRect.init(x: referenceSize.width * squareScale.xScale, y: currentYPoint, width: btnSize.width, height: btnSize.height)
                self.scrollView.addSubview(questions[i].answerBtn)
            
            questions[i].resetBtn.frame = CGRect.init(x: questions[i].answerBtn.frame.maxX + intervalLengthOfBtns, y: currentYPoint, width: btnSize.width, height: btnSize.height)
                self.scrollView.addSubview(questions[i].resetBtn)
            
            currentYPoint += btnSize.height + intervalLengthOfQuesitons
        }
    }
    
    func setQuestionNumberLabel(number: Int, questionLabel:UIImageView){
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
    

    
    func fetchQuestionDate(){
        var selectedQuestionNumber: Array<Int>! = []
        var questionList: Array<String>!
        if let csvPath = Bundle.main.path(forResource: stage.level.rawValue + String(stage.numberOfStage + 1), ofType: "csv") {
            do {
                let csvData = try String(contentsOfFile:csvPath, encoding:String.Encoding.utf8)
                questionList = csvData.components(separatedBy: ",")
            } catch let error as NSError {
                print(error.localizedDescription)
                return
            }
        }
        
        for i in 0..<numberOfQuestions{
            var random: Int!
            while true {
                random = Int(arc4random_uniform(UInt32(questionList.count)))
                let result = selectedQuestionNumber.index(of: random)
                if(result == nil){
                    break
                }
            }
            selectedQuestionNumber.append(random)
            let question = questionList[random]
            let words = question.components(separatedBy:" ")
            var wordsAndAnswers = [String : String]()
            for j in words{
                let wordAndAnswer = j.components(separatedBy: ":")
                print(wordAndAnswer[0])
                wordsAndAnswers[wordAndAnswer[0]] = wordAndAnswer[1]
            }
            
            questions.append(Question.init(numberOfQuestion: i, wordAndAnswer: wordsAndAnswers, delegate: self))
        }
        
        
    }
    
    func isStageClear()-> Bool{
        for question in questions{
            if question.clear == false{
                return false
            }
        }
        self.clearSound()
        self.timer.invalidate()
        self.gameOver(result: true)
        return true
    }
    
    func correctSound() {
        if delegate.isSoundOn(){
            if let soundUrl:NSURL = NSURL(fileURLWithPath:
                Bundle.main.path(forResource: "correct", ofType:"mp3")!) as NSURL?{
                AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                AudioServicesPlaySystemSound(soundIdRing)
            }
        }
    }
    
    func wrongSound(){
        if delegate.isSoundOn(){
            if let soundUrl:NSURL = NSURL(fileURLWithPath:
                Bundle.main.path(forResource: "wrong", ofType:"mp3")!) as NSURL?{
                AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                AudioServicesPlaySystemSound(soundIdRing)
            }
        }
    }
    
    func clearSound(){
        if delegate.isSoundOn(){
            if let soundUrl:NSURL = NSURL(fileURLWithPath:
                Bundle.main.path(forResource: "stageClear", ofType:"mp3")!) as NSURL?{
                AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                AudioServicesPlaySystemSound(soundIdRing)
            }
        }
    }
    
    func countDownSound() {
        if delegate.isSoundOn(){
            if let soundUrl:NSURL = NSURL(fileURLWithPath:
                Bundle.main.path(forResource: "countDown", ofType:"mp3")!) as NSURL?{
                AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                AudioServicesPlaySystemSound(soundIdRing)
            }
        }
    }
    
    func countDownFinishSound() {
        if delegate.isSoundOn(){
            if let soundUrl:NSURL = NSURL(fileURLWithPath:
                Bundle.main.path(forResource: "countDownFinish", ofType:"mp3")!) as NSURL?{
                AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                AudioServicesPlaySystemSound(soundIdRing)
            }
        }
    }

    
    func gameOver(result: Bool){
        self.removeObserver()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {self.delegate.moveViewControllerFromGameToGameOver(result: result, stage: self.stage)})
    }
    
    func isTouchOnSquare(point: CGPoint, question: Question)->Int?{
        for i in 0..<questions[0].squareViews.count{
            if question.squareViews[i].frame.contains(point){
                return i
            }
        }
        return nil
    }
    
    func showCorrectCircle(questionNumber: Int) {
        let frame = CGRect.init(x: questionLabelViews[questionNumber].frame.minX + (referenceSize.width * correctCircleScale.xScale), y: heightsOfQuestion[questionNumber] + (referenceSize.height * correctCircleScale.yScale), width: referenceSize.width * correctCircleScale.widthScale, height: referenceSize.height * correctCircleScale.heightScale);
        let correctCircleView = UIImageView.init(image: #imageLiteral(resourceName: "CorrectCircle"));
        correctCircleView.frame = frame;
        self.scrollView.addSubview(correctCircleView)
        scrollView.bringSubview(toFront: correctCircleView)
    }
    
    func showIncorrectCircle(questionNumber: Int){
        let frame = CGRect.init(x: questionLabelViews[questionNumber].frame.minX + (referenceSize.width * incorrectCircleScale.xScale), y: heightsOfQuestion[questionNumber] + (referenceSize.height * incorrectCircleScale.yScale), width: referenceSize.width * incorrectCircleScale.widthScale, height: referenceSize.height * incorrectCircleScale.heightScale);
        let incorrectCircleView = UIImageView.init(image: #imageLiteral(resourceName: "IncorrectCircle"));
        incorrectCircleView.frame = frame;
        self.scrollView.addSubview(incorrectCircleView)
        scrollView.bringSubview(toFront: incorrectCircleView)
        
        UIView.animate(withDuration: 1.0, animations: {()->Void in incorrectCircleView.alpha = 0.0 }, completion: {(finised:Bool)->Void in incorrectCircleView.removeFromSuperview()})
    }
    
    
    func placeCharacterOnSquare(position: Int, question:Question, characterView: CharacterView) {
        
        if question.squareViews[position].characterView != nil {
            if question.squareViews[position].characterView == characterView{
                characterView.frame.origin = question.squareViews[position].frame.origin
            }else{
                question.squareViews[position].characterView.backDefaultPosition()
                if(characterView.currentPositionInSquare != nil){
                    releaseCharacterView(position: characterView.currentPositionInSquare, question: characterView.question)
                }
                question.squareViews[position].characterView = characterView
                characterView.frame.origin = question.squareViews[position].frame.origin
            }
        }else{
            if(characterView.currentPositionInSquare != nil){
                releaseCharacterView(position: characterView.currentPositionInSquare, question: characterView.question)
            }
            question.squareViews[position].characterView = characterView
            characterView.frame.origin = question.squareViews[position].frame.origin
        }
        characterView.currentPositionInSquare = position
    }
    
    func releaseCharacterView(position: Int, question: Question) {
        question.squareViews[position].characterView = nil
    }

    func addObserver(){
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.backFromBackground), name: Notification.Name(rawValue: "backFromBackgounrdDuringGame"), object: nil)
    }
    
    @objc func backFromBackground(){
        self.timer.invalidate()
        self.gameOver(result: false)
    }
    
    func removeObserver(){
        NotificationCenter.default.removeObserver(self);
    }
    
    func disableScroll(){
        scrollView.isScrollEnabled = false
    }
    
    func enableScroll(){
        scrollView.isScrollEnabled = true
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
