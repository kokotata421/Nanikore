//
//  StageButton.swift
//  Nanikore
//
//  Created by Kota Kawanishi on 2017/03/10.
//  Copyright © 2017年 Kota Kawanishi. All rights reserved.
//

import UIKit


struct Stage{
    let level: GameLevelSelectViewController.Level
    let numberOfStage: Int
    let clear: Bool
    var numberOfQuestion: Int{
        let number = [[5,6,7,5,6,7,5,6,7,8,9,10,5,6,7,5,7,8,9,10,10,10,10,10],[5,6,7,8,9,10,5,6,7,8,9,10,5,6,7,5,6,7,5,6,7,8,9,10],[6,7,5,6,7,8,9,10,5,6,7,8,9,10,5,6,7,5,6,5,6,5,5,5]]
        switch self.level {
        case .Easy:
            return number[0][self.numberOfStage]
        case .Normal:
            return number[1][self.numberOfStage]
        case .Hard:
            return number[2][self.numberOfStage]
        }
    }
    var time: Int{
        let number = [[50,50,50,45,40,40,50,60,70,70,80,90,40,50,55,38,55,60,70,80,75,70,65,60],[40,50,60,65,75,80,35,45,50,56,63,70,75,90,105,65,78,91,60,72,84,96,108,120],[80,100,55,66,77,88,99,110,50,60,70,80,90,100,100,120,140,90,108,80,96,75,70,65]]
        switch self.level {
        case .Easy:
            return number[0][self.numberOfStage]
        case .Normal:
            return number[1][self.numberOfStage]
        case .Hard:
            return number[2][self.numberOfStage]
        }
    }
    init(level: GameLevelSelectViewController.Level, numberOfStage: Int, clear: Bool) {
        self.level = level
        self.numberOfStage = numberOfStage
        self.clear = clear
    }
    
    init(level: GameLevelSelectViewController.Level, numberOfStage: Int) {
        self.level = level
        self.numberOfStage = numberOfStage
        self.clear = false
    }
    
    func nextLevel() -> Stage! {
        switch self.level {
        case .Easy:
            return Stage.init(level: .Normal, numberOfStage: 0)
        case .Normal:
            return Stage.init(level: .Hard, numberOfStage: 0)
        default:
            return nil
        }
    }
    
    func nextStage() -> Stage!{
        return Stage.init(level: self.level, numberOfStage: self.numberOfStage + 1)
    }
    
    
}

protocol StageButtonDelegate {
    func selectStage(stageButton: StageButton)
}

class StageButton: UIButton {
    let stageStringScale = TitleViewController.Scale.init(yScale: 0.1054, widthScale: 0.6324, heightScale: 0.1918)
    let wellDoneStampScale = TitleViewController.Scale.init(xScale: 0.6424, yScale: -0.1891, sizeScale: 0.4459)
    let stageNumberViewScale = TitleViewController.Scale.init(yScale: 0.3351, widthScale: 0.1486, heightScale: 0.2351)
    let stageNumber1ViewScale = TitleViewController.Scale.init(yScale: 0.3351, widthScale: 0.0965, heightScale: 0.2351)
    let stageLockScale = TitleViewController.Scale.init(yScale: 0.1183, widthScale: 0.4772, heightScale: 0.4508)
    let stageNumberViewXScale: [CGFloat] = [0.5189, 0.3297]
    let additionOfStageNumber1ViewXScale: CGFloat = 0.01905
    let successfulCandidatesNumberViewScale = TitleViewController.Scale.init(yScale: 0.7882, widthScale: 0.0729, heightScale: 0.115)
    let successfulCandidatesNumber1ViewScale = TitleViewController.Scale.init(yScale: 0.7882, widthScale: 0.0486, heightScale: 0.115)
    let additionOfSuccessfulCandidatesNumber1ViewXScale: CGFloat = 0.00715
    let successfulCandidatesNumberViewXScale6: [CGFloat] = [0.6621, 0.581, 0.5027, 0.4243, 0.3432, 0.2648]
    let successfulCandidatesNumberViewXScale5: [CGFloat] = [0.6378, 0.5513, 0.4635, 0.3756, 0.2945]
    let successfulCandidatesNumberViewXScale4: [CGFloat] = [0.6027, 0.5081, 0.4189, 0.3243]
    let successfulCandidatesNumberViewXScale3: [CGFloat] = [0.5621, 0.4621, 0.3621]
    let successfulCandidatesNumberViewXScale2: [CGFloat] = [0.5135, 0.4135]
    var delegate: StageButtonDelegate!
    let stage: Stage!
    var stageStringImageView : UIImageView!
    
    init(frame: CGRect, level: GameLevelSelectViewController.Level, stage: Int, clear: Bool, delegate:StageButtonDelegate) {
        self.stage = Stage.init(level: level, numberOfStage: stage, clear: clear)
        super.init(frame: frame)
        self.setImage(#imageLiteral(resourceName: "StageBtn"), for: UIControlState.normal)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.delegate = delegate
    }
    
    init(level: GameLevelSelectViewController.Level, stage: Int, clear: Bool, delegate:StageButtonDelegate){
        self.stage = Stage.init(level: level, numberOfStage: stage, clear: clear)
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.setStageBtnImage()
        self.delegate = delegate
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.stage = nil
        super.init(coder: aDecoder)
        self.setImage(#imageLiteral(resourceName: "StageBtn"), for: UIControlState.normal)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
    }
    
    func setStageBtnImage(){
        switch self.stage.level {
        case .Easy:
            self.setImage(#imageLiteral(resourceName: "StageBtn_Easy"), for: UIControlState.normal)
        case .Normal:
            self.setImage(#imageLiteral(resourceName: "StageBtn_Normal"), for: UIControlState.normal)
        case .Hard:
            self.setImage(#imageLiteral(resourceName: "StageBtn_Hard"), for: UIControlState.normal)
        }
    }
    
    func addStageStringImage(){
        stageStringImageView = UIImageView.init()
        let stageStringSize = CGSize(width: self.frame.width * stageStringScale.widthScale, height: self.frame.height * stageStringScale.heightScale)
        let stageStringFrame = CGRect(x: self.bounds.midX - stageStringSize.width / 2.0, y: self.frame.height * stageStringScale.yScale, width: stageStringSize.width, height: stageStringSize.height)
        stageStringImageView = UIImageView(frame: stageStringFrame)
        stageStringImageView.image = #imageLiteral(resourceName: "StageStringOnStageBtn")
        self.addSubview(stageStringImageView)
    }
    
    
    func addWellDoneStamp(){
        let wellDoneStampFrame = CGRect(x: self.frame.width * wellDoneStampScale.xScale, y: self.bounds.height * wellDoneStampScale.yScale, width: self.frame.width * wellDoneStampScale.widthScale, height: self.frame.width * wellDoneStampScale.widthScale)
        let wellDoneStampView = UIImageView(frame: wellDoneStampFrame)
        wellDoneStampView.image = #imageLiteral(resourceName: "WellDoneStamp")
        self.addSubview(wellDoneStampView)
        self.bringSubview(toFront: stageStringImageView)
    }
    
    
    func addStageLockView(){
        let stageLockSize = CGSize(width: self.frame.width * stageLockScale.widthScale, height: self.frame.height * stageLockScale.heightScale)
        let stageLockView = UIImageView.init(frame: CGRect(x: self.bounds.midX - stageLockSize.width / 2.0 , y: self.frame.height * stageLockScale.yScale, width: stageLockSize.width, height: stageLockSize.height))
        stageLockView.image = #imageLiteral(resourceName: "StageLock")
        stageLockView.alpha = 0.9
        self.addSubview(stageLockView)
        self.isUserInteractionEnabled = false
    }
    
    
    func addStageNumberView(){
        var tempNumber = self.stage.numberOfStage + 1
        for i in 0..<2{
            var stageNumberImageString: String!
            var stageNumberImage: UIImage!
            var stageNumberViewFrame: CGRect!

            if(i == 1 && self.stage.numberOfStage + 1 < 10){
                stageNumberImage = #imageLiteral(resourceName: "StageNumber0")
            }else{
                stageNumberImageString = String.init(format: "StageNumber%d", tempNumber % 10)
                stageNumberImage = UIImage.init(named: stageNumberImageString)
            }
            if(tempNumber % 10 == 1){
                stageNumberViewFrame = CGRect(x: self.frame.width * (stageNumberViewXScale[i] + additionOfStageNumber1ViewXScale), y: self.frame.height * stageNumber1ViewScale.yScale, width: self.frame.width * stageNumber1ViewScale.widthScale, height: self.frame.height * stageNumber1ViewScale.heightScale)
            }else{
                stageNumberViewFrame = CGRect(x: self.frame.width * stageNumberViewXScale[i], y: self.frame.height * stageNumberViewScale.yScale, width: self.frame.width * stageNumberViewScale.widthScale, height: self.frame.height * stageNumberViewScale.heightScale)
            }
            let stageNumberView = UIImageView.init(frame: stageNumberViewFrame)
            stageNumberView.image = stageNumberImage
            self.addSubview(stageNumberView)
            tempNumber /= 10
        }
    }
    
    
    
    func addSuccessfulCandidates(number: Int){
        switch number {
        case 100000...999999:
            addSuccessCandidatesNumberOf6Digits(number: number)
        case 10000...99999:
            addSuccessCandidatesNumberOf5Digits(number: number)
        case 1000...9999:
            addSuccessCandidatesNumberOf4Digits(number: number)
        case 100...999:
            addSuccessCandidatesNumberOf3Digits(number: number)
        case 10...99:
            addSuccessCandidatesNumberOf2Digits(number: number)
        default:
            addSuccessCandidatesNumberOf1Digit(number: number)
        }
        
    }
    
    func addSuccessCandidatesNumberOf6Digits(number: Int){
        var tempNumber = number
        for i in 0..<6{
            var successfulCandidatesNumberImageString: String!
            var successfulCandidatesNumberImage: UIImage!
            var successfulCandidatesNumberViewFrame: CGRect!
            
            successfulCandidatesNumberImageString = String.init(format: "StageNumber%d", tempNumber % 10)
            successfulCandidatesNumberImage = UIImage.init(named: successfulCandidatesNumberImageString)
            
            if(tempNumber % 10 == 1){
                successfulCandidatesNumberViewFrame = CGRect(x: self.frame.width * (successfulCandidatesNumberViewXScale6[i] + additionOfSuccessfulCandidatesNumber1ViewXScale), y: self.bounds.height * successfulCandidatesNumber1ViewScale.yScale, width: self.frame.width * successfulCandidatesNumber1ViewScale.widthScale, height: self.frame.height * successfulCandidatesNumber1ViewScale.heightScale)
            }else{
                successfulCandidatesNumberViewFrame = CGRect(x: self.frame.width * successfulCandidatesNumberViewXScale6[i] , y: self.bounds.height * successfulCandidatesNumberViewScale.yScale, width: self.frame.width * successfulCandidatesNumberViewScale.widthScale, height: self.frame.height * successfulCandidatesNumberViewScale.heightScale)
            }
            let stageNumberView = UIImageView.init(frame: successfulCandidatesNumberViewFrame)
            stageNumberView.image = successfulCandidatesNumberImage
            self.addSubview(stageNumberView)
            tempNumber /= 10
        }

    }
    
    func addSuccessCandidatesNumberOf5Digits(number: Int){
        var tempNumber = number
        for i in 0..<5{
            var successfulCandidatesNumberImageString: String!
            var successfulCandidatesNumberImage: UIImage!
            var successfulCandidatesNumberViewFrame: CGRect!
            
            
            successfulCandidatesNumberImageString = String.init(format: "StageNumber%d", tempNumber % 10)
            successfulCandidatesNumberImage = UIImage.init(named: successfulCandidatesNumberImageString)
            
            if(tempNumber % 10 == 1){
                successfulCandidatesNumberViewFrame = CGRect(x: self.frame.width * (successfulCandidatesNumberViewXScale5[i] + additionOfSuccessfulCandidatesNumber1ViewXScale), y: self.bounds.height * successfulCandidatesNumber1ViewScale.yScale, width: self.frame.width * successfulCandidatesNumber1ViewScale.widthScale, height: self.frame.height * successfulCandidatesNumber1ViewScale.heightScale)
            }else{
                successfulCandidatesNumberViewFrame = CGRect(x: self.frame.width * successfulCandidatesNumberViewXScale5[i] , y: self.bounds.height * successfulCandidatesNumberViewScale.yScale, width: self.frame.width * successfulCandidatesNumberViewScale.widthScale, height: self.frame.height * successfulCandidatesNumberViewScale.heightScale)
            }
            let stageNumberView = UIImageView.init(frame: successfulCandidatesNumberViewFrame)
            stageNumberView.image = successfulCandidatesNumberImage
            self.addSubview(stageNumberView)
            tempNumber /= 10
        }

    }
    
    func addSuccessCandidatesNumberOf4Digits(number: Int){
        var tempNumber = number
        for i in 0..<4{
            var successfulCandidatesNumberImageString: String!
            var successfulCandidatesNumberImage: UIImage!
            var successfulCandidatesNumberViewFrame: CGRect!
            
            
            successfulCandidatesNumberImageString = String.init(format: "StageNumber%d", tempNumber % 10)
            successfulCandidatesNumberImage = UIImage.init(named: successfulCandidatesNumberImageString)
            
            if(tempNumber % 10 == 1){
                successfulCandidatesNumberViewFrame = CGRect(x: self.frame.width * (successfulCandidatesNumberViewXScale4[i] + additionOfSuccessfulCandidatesNumber1ViewXScale), y: self.bounds.height * successfulCandidatesNumber1ViewScale.yScale, width: self.frame.width * successfulCandidatesNumber1ViewScale.widthScale, height: self.frame.height * successfulCandidatesNumber1ViewScale.heightScale)
            }else{
                successfulCandidatesNumberViewFrame = CGRect(x: self.frame.width * successfulCandidatesNumberViewXScale4[i] , y: self.bounds.height * successfulCandidatesNumberViewScale.yScale, width: self.frame.width * successfulCandidatesNumberViewScale.widthScale, height: self.frame.height * successfulCandidatesNumberViewScale.heightScale)
            }
            let stageNumberView = UIImageView.init(frame: successfulCandidatesNumberViewFrame)
            stageNumberView.image = successfulCandidatesNumberImage
            self.addSubview(stageNumberView)
            tempNumber /= 10
        }

    }
    
    func addSuccessCandidatesNumberOf3Digits(number: Int){
        var tempNumber = number
        for i in 0..<3{
            var successfulCandidatesNumberImageString: String!
            var successfulCandidatesNumberImage: UIImage!
            var successfulCandidatesNumberViewFrame: CGRect!
            
            
            successfulCandidatesNumberImageString = String.init(format: "StageNumber%d", tempNumber % 10)
            successfulCandidatesNumberImage = UIImage.init(named: successfulCandidatesNumberImageString)
            
            if(tempNumber % 10 == 1){
                successfulCandidatesNumberViewFrame = CGRect(x: self.frame.width * (successfulCandidatesNumberViewXScale3[i] + additionOfSuccessfulCandidatesNumber1ViewXScale), y: self.bounds.height * successfulCandidatesNumber1ViewScale.yScale, width: self.frame.width * successfulCandidatesNumber1ViewScale.widthScale, height: self.frame.height * successfulCandidatesNumber1ViewScale.heightScale)
            }else{
                successfulCandidatesNumberViewFrame = CGRect(x: self.frame.width * successfulCandidatesNumberViewXScale3[i] , y: self.bounds.height * successfulCandidatesNumberViewScale.yScale, width: self.frame.width * successfulCandidatesNumberViewScale.widthScale, height: self.frame.height * successfulCandidatesNumberViewScale.heightScale)
            }
            let stageNumberView = UIImageView.init(frame: successfulCandidatesNumberViewFrame)
            stageNumberView.image = successfulCandidatesNumberImage
            self.addSubview(stageNumberView)
            tempNumber /= 10
        }

    }
    
    func addSuccessCandidatesNumberOf2Digits(number: Int){
        var tempNumber = number
        for i in 0..<2{
            var successfulCandidatesNumberImageString: String!
            var successfulCandidatesNumberImage: UIImage!
            var successfulCandidatesNumberViewFrame: CGRect!
            
            
            successfulCandidatesNumberImageString = String.init(format: "StageNumber%d", tempNumber % 10)
            successfulCandidatesNumberImage = UIImage.init(named: successfulCandidatesNumberImageString)
            
            if(tempNumber % 10 == 1){
                successfulCandidatesNumberViewFrame = CGRect(x: self.frame.width * (successfulCandidatesNumberViewXScale2[i] + additionOfSuccessfulCandidatesNumber1ViewXScale), y: self.bounds.height * successfulCandidatesNumber1ViewScale.yScale, width: self.frame.width * successfulCandidatesNumber1ViewScale.widthScale, height: self.frame.height * successfulCandidatesNumber1ViewScale.heightScale)
            }else{
                successfulCandidatesNumberViewFrame = CGRect(x: self.frame.width * successfulCandidatesNumberViewXScale2[i] , y: self.bounds.height * successfulCandidatesNumberViewScale.yScale, width: self.frame.width * successfulCandidatesNumberViewScale.widthScale, height: self.frame.height * successfulCandidatesNumberViewScale.heightScale)
            }
            let stageNumberView = UIImageView.init(frame: successfulCandidatesNumberViewFrame)
            stageNumberView.image = successfulCandidatesNumberImage
            self.addSubview(stageNumberView)
            tempNumber /= 10
        }

    }
    
    func addSuccessCandidatesNumberOf1Digit(number: Int){
        var successfulCandidatesNumberImageString: String!
        var successfulCandidatesNumberImage: UIImage!
        var successfulCandidatesNumberViewFrame: CGRect!
        var successfulCandidatesNumberViewSize: CGSize!
        
        
        successfulCandidatesNumberImageString = String.init(format: "StageNumber%d", number)
        successfulCandidatesNumberImage = UIImage.init(named: successfulCandidatesNumberImageString)
        
        if(number == 1){
            successfulCandidatesNumberViewSize = CGSize(width: self.frame.width * successfulCandidatesNumber1ViewScale.widthScale, height: self.frame.height * successfulCandidatesNumber1ViewScale.heightScale)
            successfulCandidatesNumberViewFrame = CGRect(x: self.bounds.midX - successfulCandidatesNumberViewSize.width / 2.0, y: self.bounds.height * successfulCandidatesNumber1ViewScale.yScale, width: successfulCandidatesNumberViewSize.width, height: successfulCandidatesNumberViewSize.height)
        }else{
            successfulCandidatesNumberViewSize = CGSize(width: self.frame.width * successfulCandidatesNumberViewScale.widthScale, height: self.frame.height * successfulCandidatesNumberViewScale.heightScale)
            successfulCandidatesNumberViewFrame = CGRect(x: self.bounds.midX - successfulCandidatesNumberViewSize.width / 2.0, y: self.bounds.height * successfulCandidatesNumber1ViewScale.yScale, width: successfulCandidatesNumberViewSize.width, height: successfulCandidatesNumberViewSize.height)        }
        let stageNumberView = UIImageView.init(frame: successfulCandidatesNumberViewFrame)
        stageNumberView.image = successfulCandidatesNumberImage
        self.addSubview(stageNumberView)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
