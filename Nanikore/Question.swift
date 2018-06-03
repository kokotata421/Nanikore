//
//  Question.swift
//  Nanikore
//
//  Created by Kota Kawanishi on 2017/04/19.
//  Copyright © 2017年 Kota Kawanishi. All rights reserved.
//

import UIKit

extension String{
    func substringWithRange(position: Int) -> String{
        return String(self[self.index(self.startIndex, offsetBy: position)..<self.index(self.startIndex, offsetBy:position + 1)])
    }
}

struct InfoOfQuestion{
    let numberOfQuestion: Int!
    let difficultyOfQuestion: Int!
    var wordAndAnswer: [String : String]!
    init(numberOfQuestion: Int, wordAndAnswer: [String : String]){
        self.numberOfQuestion = numberOfQuestion
        self.wordAndAnswer = wordAndAnswer
        self.difficultyOfQuestion = wordAndAnswer.keys.first?.count
    }
    
    func shuffleWord()->String{
        let word = wordAndAnswer.keys.first
        let characters = Array(word!)
        var shuffledWord: String!
        while true{
            shuffledWord = String()
            var numberOccupationArray = Array.init(repeating: false, count: difficultyOfQuestion)
            for _ in 0..<difficultyOfQuestion {
                while true{
                    let p = arc4random_uniform(UInt32(difficultyOfQuestion))
                    if numberOccupationArray[Int(p)] == true{
                        continue
                    }
                    numberOccupationArray[Int(p)] = true
                    shuffledWord.append(characters[Int(p)])
                    break
                }
            }
            if isWordChanged(shuffledWord: shuffledWord){
                return shuffledWord
            }
        }
    }
    
    func isWordChanged(shuffledWord: String)->Bool{
        let allPossibleWords = fetchAllPossibleAnswers(answer: shuffledWord)
        for key in wordAndAnswer.keys{
            for word in allPossibleWords{
                if key == word{
                    return false
                }
            }
        }
        return true
    }
    
    func fetchAllPossibleAnswers(answer: String) -> Array<String>{
        var stringArray:Array<String> = []
        var numberArray:Array<Int> = []
        
        self.searchCharacters(answer: answer, stringArray: &stringArray, numberArray: &numberArray)
        if numberArray.count == 0{
            return [answer]
        }
        let answerArray = self.fetchAnswerArray(answer: answer, stringArray: stringArray, numberArray: numberArray, count: numberArray.count)
        
        let orderedSet = NSOrderedSet(array: answerArray)
        let finalAnswerArray = orderedSet.array as! Array<String>
        
        return finalAnswerArray
        
    }
    
    func searchCharacters(answer:String,  stringArray: inout Array<String>, numberArray:inout Array<Int>){
        let changingCharacterArray:Array<Character> = ["つ","っ","や","ゃ","ゆ","ゅ","よ","ょ"]
        var checkString = String(answer)
        for changingCharacter in changingCharacterArray{
            if answer.contains(changingCharacter){
                while true {
                    if let range = checkString.range(of: String(changingCharacter)) {
                        numberArray.append(range.lowerBound.encodedOffset)
                        stringArray.append(String(changingCharacter))
                        if range.lowerBound.encodedOffset + 1 != range.upperBound.encodedOffset{
                            numberArray.append(range.upperBound.encodedOffset)
                            stringArray.append(String(changingCharacter))
                            checkString.replaceSubrange(range, with: "ああ")
                            break
                        }
                        checkString.replaceSubrange(range, with: "あ")
                    } else {
                        break
                    }
                }
            }
        }
        
    }
    
    func fetchAnswerArray(answer:String, stringArray:Array<String>, numberArray:Array<Int>,count: Int) -> Array<String>{
        var answerArray:Array<String> = [answer]
        for i in 1...count{
            if i == 1 || count - i == 1{
                for j in 0..<count{
                    if(i == 1){
                        answerArray.append(self.fetchNewAnswer(answer: answer, stringArray: stringArray, numberArray: numberArray, selectedNumberArray: [j]))
                    }else{
                        answerArray.append(self.fetchNewAnswer(answer: answer, stringArray: stringArray, numberArray: numberArray, selectedNumberArray: fetchNumberArrayOtherThan(number: [j], count: count)))
                    }
                }
            }else if i == 2 || count - i == 2{
                var currentBase = 0
                for j in 1...count - 1{
                    while true{
                        if i == 2{
                            answerArray.append(self.fetchNewAnswer(answer: answer, stringArray: stringArray, numberArray: numberArray, selectedNumberArray: [currentBase, currentBase + j]))
                        }else{
                            answerArray.append(self.fetchNewAnswer(answer: answer, stringArray: stringArray, numberArray: numberArray, selectedNumberArray:fetchNumberArrayOtherThan(number: [currentBase, currentBase + j], count: count)))
                        }
                        currentBase += 1
                        if(currentBase + j > count - 1){
                            break
                        }
                    }
                    currentBase = 0
                }
            }else if i == 3{
                for currentBase in 0...count - 3{
                    for j in 1...count - 2{
                        let currentBase2 = currentBase + j
                        if(currentBase2 >= count - 1){
                            break
                        }
                        for k in 1...count - 2{
                            if(currentBase2 + k > count - 1){
                                break
                            }
                            answerArray.append(self.fetchNewAnswer(answer: answer, stringArray: stringArray, numberArray: numberArray, selectedNumberArray: [currentBase, currentBase2, currentBase2 + k]))
                            
                        }
                    }
                    
                }
                
            }else{
                answerArray.append(self.fetchNewAnswer(answer: answer, stringArray: stringArray, numberArray: numberArray, selectedNumberArray:fetchNumberArrayOtherThan(number: [], count: count)))
            }
        }
        return answerArray
    }
    
    
    func fetchNumberArrayOtherThan(number: Array<Int>, count: Int) -> Array<Int>{
        var numberArray:Array<Int> = []
        for i in 0..<count{
            if number.contains(i){
                continue
            }else{
                numberArray.append(i)
            }
        }
        return numberArray
    }
    
    func fetchNewAnswer(answer:String, stringArray:Array<String>, numberArray:Array<Int>, selectedNumberArray:Array<Int>)->String{
        var answerString = String(answer)
        for i in 0..<selectedNumberArray.count{
            let replacedCharacter = replaceCharacter(character: stringArray[selectedNumberArray[i]])
            let number = numberArray[selectedNumberArray[i]]
            answerString.replaceSubrange(Range(answerString.index(answerString.startIndex, offsetBy: number)..<answerString.index(answerString.startIndex, offsetBy: number + 1)), with: replacedCharacter)
        }
        return answerString
    }
    
    func replaceCharacter(character:String) -> String{
        let nameDic:Dictionary<String, String> = ["つ":"っ", "っ":"つ", "や":"ゃ", "ゃ":"や","ゆ":"ゅ", "ゅ":"ゆ","よ":"ょ", "ょ":"よ"]
        return nameDic[character]!
    }
    
}

protocol CharacterViewProtocol {
    func isTouchOnSquare(point: CGPoint, question: Question)->Int?
    func placeCharacterOnSquare(position: Int, question:Question, characterView:CharacterView)
    func releaseCharacterView(position: Int, question: Question)
    func disableScroll()
    func enableScroll()
}



class CharacterView: UIImageView{
    
    weak var gameViewController:GameViewController! = nil
    var character: Character!
    var currentPositionInSquare: Int! = nil
    var defaultPosition: CGRect!
    weak var question: Question!
    
    
    
    init(character: Character, gameViewController:GameViewController, question:Question, frame: CGRect) {
        super.init(frame: frame)
        self.character = character
        self.gameViewController = gameViewController
        self.isUserInteractionEnabled = true
        self.setCharacterImage()
        self.defaultPosition = frame
        self.question = question
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCharacterImage(){
        switch character{
        case "ゃ":
            let imageString = "Character_や"
            self.image = UIImage.init(named: imageString)
        case "ゅ":
            let imageString = "Character_ゆ"
            self.image = UIImage.init(named: imageString)
        case "ょ":
            let imageString = "Character_よ"
            self.image = UIImage.init(named: imageString)
        case "っ":
            let imageString = "Character_つ"
            self.image = UIImage.init(named: imageString)
        default:
            var imageString = "Character_\(character!)"
            imageString = imageString.decomposedStringWithCanonicalMapping
            self.image = UIImage.init(named: imageString)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gameViewController.disableScroll()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gameViewController.disableScroll()
        let aTouch = touches.first!
        
        let location = aTouch.location(in: gameViewController.scrollView)
        
        let prevLocation = aTouch.previousLocation(in: gameViewController.scrollView)
        
        var myFrame: CGRect = self.frame
        
        let deltaX: CGFloat = location.x - prevLocation.x
        let deltaY: CGFloat = location.y - prevLocation.y
        
        myFrame.origin.x += deltaX
        myFrame.origin.y += deltaY
        
        self.frame = myFrame
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let point = touch?.location(in: gameViewController.scrollView)
        let result = gameViewController.isTouchOnSquare(point: point!, question: self.question)
        if result == nil{
            self.backPosition()
        }else{
            gameViewController.placeCharacterOnSquare(position: result!,question: self.question, characterView: self)
        }
        self.gameViewController.enableScroll()
    }
    
    func backPosition(){
        if currentPositionInSquare == nil{
            backDefaultPosition()
        }else{
            gameViewController.placeCharacterOnSquare(position: currentPositionInSquare, question: self.question, characterView: self)
        }
    }
    
    func backDefaultPosition(){
        if(self.currentPositionInSquare != nil){
            self.gameViewController.releaseCharacterView(position: self.currentPositionInSquare, question: self.question)
        }
        self.currentPositionInSquare = nil
        self.frame = defaultPosition
    }
    
}

class BlankSquareView: UIView{
    weak var characterView: CharacterView! = nil
    override init(frame:CGRect){
        super.init(frame:frame)
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

protocol QuestionProtocol {
    func isStageClear()->Bool
    func showCorrectCircle(questionNumber: Int)
    func showIncorrectCircle(questionNumber: Int)
    func wrongSound()
    func correctSound()
    func clearSound()
}


class Question: NSObject {
    var info: InfoOfQuestion!
    var squareViews = Array<BlankSquareView>()
    var characterViews = Array<CharacterView>()
    let answerBtn = UIButton.init()
    let resetBtn = UIButton.init()
    var clear: Bool = false
    var delegate: QuestionProtocol!
    
    init(numberOfQuestion: Int, wordAndAnswer: [String: String]!, delegate: QuestionProtocol!) {
        super.init()
        info = InfoOfQuestion.init(numberOfQuestion: numberOfQuestion, wordAndAnswer: wordAndAnswer)
        self.answerBtn.setImage(#imageLiteral(resourceName: "AnswerBtn"), for: UIControlState.normal)
        self.answerBtn.addTarget(self, action: #selector(isAnswerRight), for: UIControlEvents.touchUpInside)
        self.resetBtn.setImage(#imageLiteral(resourceName: "ResetBtn"), for: UIControlState.normal)
        self.resetBtn.addTarget(self, action: #selector(reset), for: UIControlEvents.touchUpInside)
        self.delegate = delegate
    }
    
    @objc func isAnswerRight(){
    
        for squareView in squareViews{
            if squareView.characterView == nil{
                self.delegate.wrongSound()
                self.delegate.showIncorrectCircle(questionNumber: self.info.numberOfQuestion)
                return
            }
        }
        var answerString = String.init(squareViews[0].characterView.character)
        for i in 1..<squareViews.count{
            answerString.append(squareViews[i].characterView.character)
        }
        let allAnswers = info.fetchAllPossibleAnswers(answer: answerString)
        print(allAnswers)
        for answer in allAnswers{
            for corectAnswer in self.info.wordAndAnswer.keys{
                if answer == corectAnswer{
                    self.delegate.showCorrectCircle(questionNumber: self.info.numberOfQuestion)
                    self.disableTouchCharacterViews()
                    self.answerBtn.isUserInteractionEnabled = false
                    self.resetBtn.isUserInteractionEnabled = false
                    clear = true
                    self.reviseCharacterViews(correctAnswer: corectAnswer)
                    if self.delegate.isStageClear() {
                        return
                    }else{
                        self.delegate.correctSound()
                        return
                    }
                    
                }
            }
        }
        self.delegate.wrongSound()
        self.delegate.showIncorrectCircle(questionNumber: self.info.numberOfQuestion)
    }
    
    func reviseCharacterViews(correctAnswer:String){
        let changingCharacterArray:Array<Character> = ["っ","ゃ","ゅ","ょ"]
        let characters = correctAnswer
        for i in 0..<characters.count{
            let character = characters[characters.index(characters.startIndex, offsetBy: i)]
            for changingCharacter in changingCharacterArray{
                if character == changingCharacter{
                    reviseCharacterView(characterView: squareViews[i].characterView)
                }
            }
        }
    }
    
    func reviseCharacterView(characterView:CharacterView){
        if characterView.character == "っ" || characterView.character == "つ"{
            characterView.image = UIImage.init(named: "Character_っ")
        }else if characterView.character == "ゃ" || characterView.character == "や"{
            characterView.image = UIImage.init(named: "Character_ゃ")
        }else if characterView.character == "ゅ" || characterView.character == "ゆ"{
            characterView.image = UIImage.init(named: "Character_ゅ")
        }else if characterView.character == "ょ" || characterView.character == "よ"{
            characterView.image = UIImage.init(named: "Character_ょ")
        }
    }
    
    func disableTouchCharacterViews(){
        for view in self.characterViews{
            view.isUserInteractionEnabled = false
        }
    }
    
    @objc func reset(){
        for i in 0..<squareViews.count{
            squareViews[i].characterView = nil
            characterViews[i].backDefaultPosition()
        }
    }
}

