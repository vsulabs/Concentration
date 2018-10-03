//
//  ViewController.swift
//  SetGame
//
//  Created by xcode on 26.09.2018.
//  Copyright © 2018 VSU. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameNotifier {
    func cardSelected(cardId: Int) {
        cards[cardId].backgroundColor = UIColor.brown
    }
    
    func cardUnselected(cardId: Int) {
        cards[cardId].backgroundColor = UIColor.white
    }
    
    func cardReplaced(cardId: Int, card: Card) {
        cardAdded(cardId: cardId, card: card)
    }
    
    func cardRemoved(cardId: Int) {
        cards[cardId].alpha = 0
    }
    
    func setNotMatched(cardIds: [Int]) {
        for cardId in cardIds {
            cards[cardId].backgroundColor = UIColor.purple
        }
    }
    
    func setMatched(cardIds: [Int]) {
        for cardId in cardIds {
            cards[cardId].backgroundColor = UIColor.orange
        }
    }
    
    func getCharFromFigure(_ figure: Figure) -> String {
        switch(figure) {
        case .Circle:
            return "●"
        case .Triangle:
            return "▲"
        case .Rectangle:
            return "■"
        }
    }
    
    func getUIColorFromColor(_ color: Color) -> UIColor {
        switch(color) {
        case .Red:
            return UIColor.red
        case .Green:
            return UIColor.green
        case .Blue:
            return UIColor.blue
        }
    }
    
    func cardAdded(cardId: Int, card: Card) {
        cards[cardId].alpha = 1
        
        let char = getCharFromFigure(card.figure)
        let figure = String(repeating: char, count: card.count)
        cards[cardId].setTitle(figure, for: UIControlState.normal)
        
        let color = getUIColorFromColor(card.color)
        cards[cardId].setTitleColor(color, for: UIControlState.normal)
    }

    
    @IBOutlet var cards: [UIButton]!
    
    var gameManager: SetGame?
    
    func newGame() {
        for card in cards {
            card.alpha = 0
            card.backgroundColor = UIColor.white
        }
        
        gameManager?.reset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for btn in cards {
            btn.addTarget(self, action: #selector(openCard), for: .touchUpInside)
        }
        gameManager = SetGame(notifier: self)
        newGame()
    }
    
    @IBAction func deal3MoreCards() {
        gameManager?.deal(cardCount: 3)
    }
    
    @objc func openCard(sender: UIButton) {
        guard let cardId = cards.index(of: sender) else {
            return
        }
        gameManager?.selectCard(cardId: cardId)
    }
    
    
}

