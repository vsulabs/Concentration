//
//  ViewController.swift
//  Concentration
//
//  Created by xcode on 05.09.2018.
//  Copyright © 2018 VSU. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CardObserver {

    let model = Concentration()
    let themes = [
        Theme(
            openColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),
            closeColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            emoji: ["☭", "⚒︎", "★", "🇨🇳", "🇰🇵", "🇻🇳"]
        ),
        Theme(
            openColor: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1),
            closeColor: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),
            emoji: ["🐶", "🐷", "🐸", "🐔", "🐵", "🕷"]
        ),
        Theme(
            openColor: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1),
            closeColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),
            emoji: ["😀", "🤢", "😈", "😎", "😡", "😱"]
        ),
        Theme(
            openColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),
            closeColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1),
            emoji: ["🍎", "🍉", "🍓", "🍒", "🥝", "🍆"]
        ),
        Theme(
            openColor: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1),
            closeColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1),
            emoji: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐"]
        ),
        Theme(
            openColor: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1),
            closeColor: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1),
            emoji: ["𝛼", "𝛽", "𝛾", "𝛿", "𝜀", "𝜁"]
        )
    ]
    var theme = Theme()
    
    func didOpenCard(cardNum: Int, type: Int) {
        cardButtons[cardNum].backgroundColor = theme.openColor
        cardButtons[cardNum].setTitle(theme.emoji[type], for: UIControlState.normal)
    }
    
    func didCloseCard(cardNum: Int) {
        cardButtons[cardNum].backgroundColor = theme.closeColor
        cardButtons[cardNum].setTitle("", for: UIControlState.normal)
    }
    
    func didChangeScore(score: Int) {
        scoreLabel.text = "Score: \(score)"
    }
    
    func didChangeFlipCount(count: Int) {
        flipCountLabel.text = "Flip count: \(count)"
    }
    
    // UI part
    
    @IBOutlet var flipCountLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var cardButtons: [UIButton]!
    
    
    override func viewDidLoad() {
        model.setObserver(obs: self)
        newGameStarted()
    }
    
    @IBAction func newGameStarted() {
        let maxThemeIndex = UInt32(themes.count)
        let themeIndex = Int(arc4random_uniform(maxThemeIndex))
        theme = themes[themeIndex]
        model.reset()
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        guard let cardId = cardButtons.index(of: sender) else {
            print("Card not found")
            return
        }
        
        model.openCard(cardId)
    }
}
