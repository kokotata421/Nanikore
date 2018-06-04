//
//  TitleViewController.swift
//  Nanikore
//
//  Created by Kota Kawanishi on 2017/03/05.
//  Copyright © 2017年 Kota Kawanishi. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol TitleViewControllerProtocol{
    func playBGM()
    func touchSound()
    func touchSound2()
    func switchSound() -> Bool
    func moveViewControllerFromTitleToGameLevelSelect()
}

class TitleViewController: UIViewController, GADBannerViewDelegate{
    
    struct Scale{
        let xScale: CGFloat
        let yScale: CGFloat
        let widthScale: CGFloat
        let heightScale: CGFloat
        
        init(xScale: CGFloat, yScale: CGFloat, widthScale: CGFloat, heightScale: CGFloat){
            self.xScale = xScale
            self.yScale = yScale
            self.widthScale = widthScale
            self.heightScale = heightScale
        }
        
        init(xScale: CGFloat, widthScale: CGFloat, heightScale: CGFloat) {
            self.xScale = xScale
            self.yScale = 0.0
            self.widthScale = widthScale
            self.heightScale = heightScale
        }
        
        init(yScale: CGFloat, widthScale: CGFloat, heightScale: CGFloat) {
            self.xScale = 0.0
            self.yScale = yScale
            self.widthScale = widthScale
            self.heightScale = heightScale
        }
        
        init(xScale: CGFloat, yScale: CGFloat, sizeScale: CGFloat){
            self.xScale = xScale
            self.yScale = yScale
            self.widthScale = sizeScale
            self.heightScale = 0.0
        }
        
        init(yScale: CGFloat, sizeScale: CGFloat){
            self.xScale = 0.0
            self.yScale = yScale
            self.widthScale = sizeScale
            self.heightScale = 0.0
        }
        
        init(xScale: CGFloat, sizeScale: CGFloat){
            self.xScale = xScale
            self.yScale = 0.0
            self.widthScale = sizeScale
            self.heightScale = 0.0
        }
        
        init(widthScale: CGFloat, heightScale: CGFloat) {
            self.xScale = 0.0
            self.yScale = 0.0
            self.widthScale = widthScale
            self.heightScale = heightScale
        }

    }
    //Views
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var soundBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var howToPlayBtn: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    let explanationView = UIImageView.init(image: #imageLiteral(resourceName: "ExplanationImage1"))
    let explanationBackgroundView = UIView()
    let nextArrow = UIButton.init()
    let backArrow = UIButton.init()
    let backBtn = UIButton.init()
    
    //Delegate
    var delegate: TitleViewControllerProtocol! = nil
    
    //Data
    var pageNumber = 1
    var referenceSize: CGSize!
    
    //Scale
    let soundBtnScale: Scale = Scale.init(xScale: 0.041, yScale: 0.0336, sizeScale: 0.1892)
    let mainBtnsScale: Scale = Scale.init(yScale: 0.6039, widthScale: 0.3621, heightScale: 0.0908)
    let btnsInterval: CGFloat = 0.0402
    let iconScale: Scale = Scale.init(yScale: 0.174, widthScale: 1.0, heightScale: 0.249)
    let explanationViewSizeScale = Scale.init(widthScale: 0.7848, heightScale: 0.6993)
    let arrowScale: TitleViewController.Scale = Scale.init(xScale: 0.0289, yScale: 0.8849, widthScale: 0.2979, heightScale: 0.0825)
    let backBtnScale = Scale.init(xScale: 0.6933, yScale: 0.0416,widthScale: 0.2436, heightScale: 0.08666)
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        referenceSize = self.view.frame.size
        self.delegate = self.parent as! TitleViewControllerProtocol
        configureViews()
        configureExplanationViews()
        //showBannerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.delegate.playBGM()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureViews() {
        let mainIconFrame = CGRect(x: 0.0, y: referenceSize.height * iconScale.yScale, width: referenceSize.width, height: referenceSize.height * iconScale.heightScale)
        let soundBtnFrame = CGRect(x: referenceSize.width * soundBtnScale.xScale, y: referenceSize.height * soundBtnScale.yScale, width: referenceSize.width * soundBtnScale.widthScale, height: referenceSize.width * soundBtnScale.widthScale)
        let mainBtnsSize = CGSize(width: referenceSize.width * mainBtnsScale.widthScale, height: referenceSize.height * mainBtnsScale.heightScale)
        let playBtnFrame = CGRect(x: (referenceSize.width / 2.0) - mainBtnsSize.width - (referenceSize.width * btnsInterval), y: referenceSize.height * mainBtnsScale.yScale, width: mainBtnsSize.width, height: mainBtnsSize.height)
        let howToPlayBtnFrame = CGRect(x: (referenceSize.width / 2.0) + (referenceSize.width * btnsInterval), y: referenceSize.height * mainBtnsScale.yScale, width: mainBtnsSize.width, height: mainBtnsSize.height)
        
        iconView.frame = mainIconFrame
        soundBtn.frame = soundBtnFrame
        playBtn.frame = playBtnFrame
        howToPlayBtn.frame = howToPlayBtnFrame
    }
    
    func configureExplanationViews(){
        explanationBackgroundView.frame = CGRect.init(x: 0, y: 0, width: referenceSize.width, height: referenceSize.height)
        explanationBackgroundView.backgroundColor = UIColor.black
        explanationBackgroundView.alpha = 0.8
        
        let explanationViewSize = CGSize.init(width: referenceSize.width * explanationViewSizeScale.widthScale, height: referenceSize.height * explanationViewSizeScale.heightScale)
        explanationView.frame = CGRect.init(x: referenceSize.width / 2.0 - explanationViewSize.width / 2.0, y: referenceSize.height / 2.0 - explanationViewSize.height / 2.0, width: explanationViewSize.width, height: explanationViewSize.height)
        
        let arrowFrame = CGRect(x: referenceSize.width * arrowScale.xScale, y: referenceSize.height * arrowScale.yScale, width: referenceSize.width * arrowScale.widthScale, height: referenceSize.height * arrowScale.heightScale)
        backArrow.frame = arrowFrame
        nextArrow.frame = CGRect.init(x: referenceSize.width - arrowFrame.maxX, y: arrowFrame.minY, width: arrowFrame.width, height: arrowFrame.height)
        backArrow.setImage(#imageLiteral(resourceName: "BackArrow"), for: UIControlState.normal)
        nextArrow.setImage(#imageLiteral(resourceName: "NextArrow"), for: UIControlState.normal)
        backArrow.addTarget(self, action: #selector(backPage), for: UIControlEvents.touchUpInside)
        nextArrow.addTarget(self, action: #selector(nextPage), for: UIControlEvents.touchUpInside)
        
        backBtn.setImage(#imageLiteral(resourceName: "BackBtn"), for: UIControlState.normal)
        backBtn.frame = CGRect.init(x: referenceSize.width * backBtnScale.xScale, y: referenceSize.height * backBtnScale.yScale, width: referenceSize.width * backBtnScale.widthScale, height: (referenceSize.height - bannerView.adSize.size.height) * backBtnScale.heightScale)
        backBtn.isUserInteractionEnabled = true
        backBtn.addTarget(self, action: #selector(backTitle), for: UIControlEvents.touchUpInside)
    }
    
    @objc func backTitle(){
        playBtn.isUserInteractionEnabled = true
        howToPlayBtn.isUserInteractionEnabled = true
        soundBtn.isUserInteractionEnabled = true
        for view in explanationBackgroundView.subviews{
            view.removeFromSuperview()
        }
        
        explanationBackgroundView.removeFromSuperview()
        explanationView.removeFromSuperview()
    }
    
    func showArrows(){
        if(backArrow.isDescendant(of: self.explanationBackgroundView)){
            backArrow.removeFromSuperview()
        }
        if(nextArrow.isDescendant(of: self.explanationBackgroundView)){
            nextArrow.removeFromSuperview()
        }
        
        switch pageNumber{
        case 1: self.explanationBackgroundView.addSubview(nextArrow)
        case 2: self.explanationBackgroundView.addSubview(backArrow)
        default: break;
        }

    }
    
    @objc func nextPage(){
        self.delegate.touchSound2()
        pageNumber += 1
        self.explanationView.image = #imageLiteral(resourceName: "ExplanationImage2")
        self.showArrows()
    }
    
    @objc func backPage(){
        self.delegate.touchSound2()
        pageNumber -= 1
        self.explanationView.image = #imageLiteral(resourceName: "ExplanationImage1")
        self.showArrows()
    }
    
    func showExplanation(){
        pageNumber = 1
        playBtn.isUserInteractionEnabled = false
        howToPlayBtn.isUserInteractionEnabled = false
        soundBtn.isUserInteractionEnabled = false
        explanationView.image = #imageLiteral(resourceName: "ExplanationImage1")
        self.view.addSubview(explanationBackgroundView)
        self.view.addSubview(explanationView)
        self.explanationBackgroundView.addSubview(backBtn)
        self.view.bringSubview(toFront: bannerView)
        self.showArrows()
    }
    
    @IBAction func play(_ sender: Any){
        self.delegate.touchSound()
        self.delegate.moveViewControllerFromTitleToGameLevelSelect()
    }

    @IBAction func showHowToPlay(_ sender: Any) {
        self.delegate.touchSound()
        self.showExplanation()
        
    }
    @IBAction func switchSoundOn(_ sender: Any) {
        if self.delegate.switchSound(){
            soundBtn.setImage(#imageLiteral(resourceName: "SoundOn"), for: UIControlState.normal)
        }else{
            soundBtn.setImage(#imageLiteral(resourceName: "SoundOff"), for: UIControlState.normal)
        }
    }
    
    fileprivate func showBannerView(){
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.frame.origin = CGPoint.init(x: 0, y: referenceSize.height - bannerView.frame.height)
        bannerView.adUnitID = "ca-app-pub-8719818866106636/9596083301"
        bannerView.delegate = self as GADBannerViewDelegate
        bannerView.rootViewController = self
        let gadRequest:GADRequest = GADRequest()
        
        //bannerView.load(gadRequest)
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
