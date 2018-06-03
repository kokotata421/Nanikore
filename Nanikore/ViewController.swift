//
//  ViewController.swift
//  Nanikore
//
//  Created by Kota Kawanishi on 2017/03/04.
//  Copyright © 2017年 Kota Kawanishi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, TitleViewControllerProtocol, GameRecordViewControllerProtocol,GameViewControllerProtocol, GameOverViewControllerProtocol, GameLevelSelectViewControllerProtocol, AnswerViewControllerProtocol{
    
    let kTitleViewCtr = "Title"
    let kGameLevelSelectViewCtr = "GameLevelSelect"
    let kGameViewCtr = "Game"
    let kGameRecordViewCtr = "GameRecord"
    let kGameOverViewCtr = "GameOver"
    let kAnswerViewCtr = "Answer"
    
    var titleViewCtr: TitleViewController!
    var gameLevelSelectViewCtr: GameLevelSelectViewController!
    var gameViewCtr: GameViewController!
    var gameRecordViewCtr: GameRecordViewController!
    var gameOverViewCtr: GameOverViewController!
    var answerViewCtr: AnswerViewController!
    var soundIdRing:SystemSoundID = 0
    var soundOn: Bool = true
    var audioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.createViewControllers()
        self.setUpAudio()
        
    }
    
    func createViewControllers(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        titleViewCtr = storyboard.instantiateViewController(withIdentifier: kTitleViewCtr)as! TitleViewController
        gameLevelSelectViewCtr = storyboard.instantiateViewController(withIdentifier: kGameLevelSelectViewCtr)as! GameLevelSelectViewController
        gameViewCtr = storyboard.instantiateViewController(withIdentifier: kGameViewCtr)as! GameViewController
        gameRecordViewCtr = storyboard.instantiateViewController(withIdentifier: kGameRecordViewCtr)as! GameRecordViewController
        gameOverViewCtr = storyboard.instantiateViewController(withIdentifier: kGameOverViewCtr)as! GameOverViewController
        answerViewCtr = storyboard.instantiateViewController(withIdentifier: kAnswerViewCtr)as! AnswerViewController
        displayContentController(content: titleViewCtr)
    }
    
    
    func displayContentController(content:UIViewController){
        addChildViewController(content)
        content.view.frame = self.view.bounds
        self.view.addSubview(content.view)
        content.didMove(toParentViewController: self);
    }
    
    func hideContentController(content:UIViewController){
        content.willMove(toParentViewController: nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }
    
    func cycleFromViewController(oldC :UIViewController, toNewC: UIViewController){
        oldC.willMove(toParentViewController: nil)

        self.addChildViewController(toNewC)
        
        self.transition(from: oldC, to: toNewC, duration: 0, options: UIViewAnimationOptions(rawValue: 0), animations: nil, completion:{_ in
            oldC.removeFromParentViewController()
            toNewC.didMove(toParentViewController: self)
        })
    }
    

    
    func setUpAudio(){
        let audioPath = NSURL(fileURLWithPath: Bundle.main.path(forResource: "nanikore_title_bgm", ofType: "mp3")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioPath as URL)
            audioPlayer.delegate = self
        }catch {
            print("AVAudioPlayer error")
        }
    }
    
    func playBGM() {
        if soundOn{
            if(!audioPlayer.isPlaying){
                audioPlayer.volume = 1.0
                audioPlayer.numberOfLoops = -1
                audioPlayer.play()
            }
        }
    }
    
    
    func touchSound() {
        if soundOn{
            if let soundUrl:NSURL = NSURL(fileURLWithPath:
                Bundle.main.path(forResource: "decisionSound", ofType:"mp3")!) as NSURL?{
                AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                AudioServicesPlaySystemSound(soundIdRing)
            }
        }
    }
    
    func touchSound2(){
        if soundOn{
            if let soundUrl:NSURL = NSURL(fileURLWithPath:
                Bundle.main.path(forResource: "touchSound", ofType:"mp3")!) as NSURL?{
                AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                AudioServicesPlaySystemSound(soundIdRing)
            }
        }
    }
    
    
    func successSound() {
        if soundOn{
            if let soundUrl:NSURL = NSURL(fileURLWithPath:
                Bundle.main.path(forResource: "clearSound", ofType:"mp3")!) as NSURL?{
                AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                AudioServicesPlaySystemSound(soundIdRing)
            }
        }
    }
    
    
    func failureSound(){
        if soundOn{
            if let soundUrl:NSURL = NSURL(fileURLWithPath:
                Bundle.main.path(forResource: "failureSound", ofType:"mp3")!) as NSURL?{
                AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                AudioServicesPlaySystemSound(soundIdRing)
            }
        }
    }
    
    func stampSound() {
        if soundOn{
            if let soundUrl:NSURL = NSURL(fileURLWithPath:
                Bundle.main.path(forResource: "stampSound", ofType:"wav")!) as NSURL?{
                AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                AudioServicesPlaySystemSound(soundIdRing)
            }
        }
    }
    
    func turnBGMDown(){
        if soundOn{
            audioPlayer.volume = 0.6
        }
    }
    
    func stopBGM(){
        if(audioPlayer.isPlaying){
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        }
    }
    
    func moveViewControllerFromTitleToGameLevelSelect() {
        cycleFromViewController(oldC: titleViewCtr, toNewC: gameLevelSelectViewCtr)
    }
    
    func moveViewControllerFromGameLevelSelectToTitle() {
        cycleFromViewController(oldC: gameLevelSelectViewCtr, toNewC: titleViewCtr)
    }
    
    func moveViewControllerFromGameLevelSelectToGameRecord(stage: Stage) {
        gameRecordViewCtr.selectedStage = stage
        cycleFromViewController(oldC: gameLevelSelectViewCtr, toNewC: gameRecordViewCtr)
    }
    
    func moveViewControllerFromGameRecordToGameLevelSelect() {
        cycleFromViewController(oldC: gameRecordViewCtr, toNewC: gameLevelSelectViewCtr)
    }
    
    func moveViewControllerFromGameRecordToGame(stage: Stage) {
        gameViewCtr.stage = stage
        cycleFromViewController(oldC: gameRecordViewCtr, toNewC: gameViewCtr)
    }
    func moveViewControllerFromGameToGameOver(result:Bool, stage:Stage) {
        gameOverViewCtr.stage = stage
        gameOverViewCtr.result = result
        
        if result{
            gameOverViewCtr.recordTime = gameViewCtr.stage.time - gameViewCtr.timeLeft
        }else{
            gameOverViewCtr.recordTime = nil
        }
        
        var answers = [[String : String]]()
        

        for i in 0..<gameViewCtr.questions.count{
            answers.append(gameViewCtr.questions[i].info.wordAndAnswer)
        }
        gameViewCtr.questions.removeAll()
        gameViewCtr.minViews.removeAll()
        gameViewCtr.secViews.removeAll()
        
        answerViewCtr.answers = answers
        answerViewCtr.result = result
        answerViewCtr.stage = stage
        for view in gameViewCtr.timeLeftFrameView.subviews{
            view.removeFromSuperview()
        }
        
        for view in gameViewCtr.scrollView.subviews{
            view.removeFromSuperview()
        }
        
        for view in gameViewCtr.levelStageLabel.subviews{
            view.removeFromSuperview()
        }
        
        for view in gameViewCtr.view.subviews{
            view.removeFromSuperview()
        }
        self.gameViewCtr.scrollView.contentOffset = CGPoint.init(x: 0, y: -self.gameViewCtr.scrollView.contentInset.top)
        self.gameViewCtr.scrollView.removeFromSuperview()
        cycleFromViewController(oldC: gameViewCtr, toNewC: gameOverViewCtr)
        
    }
    
    func moveViewControllerFromGameOverToTitle() {
        gameOverViewCtr.removeViews()
        self.cycleFromViewController(oldC: gameOverViewCtr, toNewC: titleViewCtr)
    }
    
        
    func moveViewControllerFromGameOverToAnswer() {
        gameOverViewCtr.removeViews()
        self.cycleFromViewController(oldC: gameOverViewCtr, toNewC: answerViewCtr)
    }
    
    func moveViewControllerFromGameOverToGame(stage: Stage) {
        gameOverViewCtr.removeViews()
        gameViewCtr.stage = stage
        self.cycleFromViewController(oldC: gameOverViewCtr, toNewC: gameViewCtr)
    }
    
    func moveViewControllerFromAnswerToGame(stage: Stage) {
        gameViewCtr.stage = stage
        for view in answerViewCtr.levelStageLabel.subviews{
            view.removeFromSuperview()
        }
        
        for view in answerViewCtr.scrollView.subviews{
            view.removeFromSuperview()
        }
        
        for view in answerViewCtr.view.subviews{
            if view != answerViewCtr.bannerView{
                view.removeFromSuperview()
            }
        }
        cycleFromViewController(oldC: answerViewCtr, toNewC: gameViewCtr)

    }
    
    func moveViewControllerFromAnswerToTitle() {
        for view in answerViewCtr.levelStageLabel.subviews{
            view.removeFromSuperview()
        }
        for view in answerViewCtr.view.subviews{
            if view != answerViewCtr.bannerView{
                view.removeFromSuperview()
            }
        }
        cycleFromViewController(oldC: answerViewCtr, toNewC: titleViewCtr)

    }
    
     func switchSound() -> Bool{
        soundOn = !soundOn
        if soundOn{
            playBGM()
            return true
        }else{
            stopBGM()
            return false
        }
    }
    
    func isSoundOn() -> Bool{
        return self.soundOn
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

