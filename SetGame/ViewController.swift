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
        grid.cards[cardId].isSelected = true
    }
    
    func cardUnselected(cardId: Int) {
        grid.cards[cardId].isSelected = false
        grid.cards[cardId].isMatched = nil
    }
    
    func cardReplaced(cardId: Int, card: Card) {
        var cards = grid.cards
        let cardView = CardView(card)
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapCard(recognizedBy: ))
        )
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        cardView.addGestureRecognizer(tap)
        
        cards[cardId] = cardView
        grid.cards = cards
    }
    
    func cardRemoved(cardId: Int) {
        var cards = grid.cards
        cards.remove(at: cardId)
        grid.cards = cards
    }
    
    func setNotMatched(cardIds: [Int]) {
        for cardId in cardIds {
            grid.cards[cardId].isMatched = false
        }
    }
    
    func setMatched(cardIds: [Int]) {
        for cardId in cardIds {
            grid.cards[cardId].isMatched = true
        }
    }
    
    func cardAdded(cardId: Int, card: Card) {
        var cards = grid.cards
        let cardView = CardView(card)
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapCard(recognizedBy: ))
        )
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        cardView.addGestureRecognizer(tap)
        
        cards.append(cardView)
        grid.cards = cards
    }

    
    @IBOutlet weak var grid: GridView!
    
    var gameManager: SetGame?
    
    func newGame() {
        for card in grid.cards {
            card.alpha = 0
            card.backgroundColor = UIColor.white
        }
        
        gameManager?.reset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameManager = SetGame(notifier: self)
        newGame()
        let rotate = UIRotationGestureRecognizer(
            target: self,
            action: #selector(reshuffle(recognizedBy: ))
        )
        grid.addGestureRecognizer(rotate)
        
        let swipeDown = UISwipeGestureRecognizer(
            target: self,
            action: #selector(deal3MoreCardsGesture(recognizedBy: ))
        )
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        grid.addGestureRecognizer(swipeDown)
    }
    
    @IBAction func deal3MoreCards() {
        gameManager?.deal(cardCount: 3)
    }
    
    @IBAction func reshuffle(recognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            gameManager?.shuffle()
        default:
            break
        }
    }
    
    @objc
    private func deal3MoreCardsGesture(recognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            gameManager?.deal(cardCount: 3)
        default:
            break
        }
    }
    
    @objc
    private func tapCard(recognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            openCard(recognizer.view! as! CardView)
        default:
            break
        }
    }
    
    @objc
    func openCard(_ sender: CardView) {
        guard let cardId = grid.cards.index(of: sender) else {
            return
        }
        gameManager?.selectCard(cardId: cardId)
    }
    
    
}

