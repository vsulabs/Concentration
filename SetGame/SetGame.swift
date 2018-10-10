//
//  SetGame.swift
//  SetGame
//
//  Created by xcode on 26.09.2018.
//  Copyright © 2018 VSU. All rights reserved.
//

import Foundation

enum Figure {
    case Diamond
    case Squiggle
    case Oval
}

enum Color {
    case Red
    case Green
    case Blue
}

enum Fill {
    case Unfilled
    case Striped
    case Solid
}

struct Card {
    var count: Int
    var figure: Figure
    var color: Color
    var fill: Fill
}

protocol GameNotifier {
    func cardAdded(cardId: Int, card: Card)
    func cardSelected(cardId: Int)
    func cardUnselected(cardId: Int)
    
    func cardReplaced(cardId: Int, card: Card)
    func cardRemoved(cardId: Int)
    
    func setMatched(cardIds: [Int])
    func setNotMatched(cardIds: [Int])
}

class SetGame
{
    static let maxFigureCount = 3;
    static let totalCardCount = maxFigureCount * 3 * 3;
    static let cardCountForFirstDeal = 12
    var deck: [Card] = []
    var selectedCardIds = [-1, -1, -1]
    var dealedCardCount = 0
    var dealedCardIds: [Int] = []
    
    let notifier: GameNotifier
    
    init(notifier: GameNotifier) {
        self.notifier = notifier
    }
    
    func reset() {
        deck.removeAll()
        for count in 1...SetGame.maxFigureCount {
            for color in [ Color.Red, Color.Green, Color.Blue ] {
                for figure in [ Figure.Diamond, Figure.Squiggle, Figure.Oval ] {
                    for fill in [ Fill.Solid, Fill.Striped, Fill.Unfilled ] {
                        let card = Card(count: count, figure: figure, color: color, fill: fill)
                        deck.append(card)
                    }
                }
            }
        }
        
        for i in 0..<SetGame.totalCardCount {
            let newPosition = Int(arc4random_uniform(UInt32(SetGame.totalCardCount)))
            deck.swapAt(i, newPosition)
        }
        
        deal(cardCount: SetGame.cardCountForFirstDeal)
    }
    
    func deal(cardCount: Int) {
        let selectedAll3Cards = !selectedCardIds.contains(-1)
        if selectedAll3Cards {
            resetSelectedCards()
            return
        }
        
        if dealedCardCount + cardCount >= SetGame.totalCardCount {
            return
        }
        
        for i in 0..<cardCount {
            let id = dealedCardCount + i
            var cardId = -1
            if dealedCardIds.contains(-1) {
                cardId = dealedCardIds.index(of: -1)!
                dealedCardIds[cardId] = id
            } else {
                cardId = dealedCardIds.count
                dealedCardIds.append(id)
            }
            
            notifier.cardAdded(cardId: cardId, card: deck[id])
        }
        
        dealedCardCount += cardCount
    }
    
    func compareCards(isEqual: (_ first: Card, _ second: Card) -> Bool) -> Bool {
        for i in 0..<2 {
            let cur = dealedCardIds[selectedCardIds[i]]
            let next = dealedCardIds[selectedCardIds[i + 1]]
            if !isEqual(deck[cur], deck[next]) {
                return false
            }
        }
        return true
    }
    
    func isMatch() -> Bool {
        let equalCount = { (_ first: Card, _ second: Card) in
            return first.count == second.count
        }
        let equalFigure = { (_ first: Card, _ second: Card) in
            return first.figure == second.figure
        }
        let equalColor = { (_ first: Card, _ second: Card) in
            return first.color == second.color
        }
        
        return compareCards(isEqual: equalCount) ||
               compareCards(isEqual: equalFigure) ||
               compareCards(isEqual: equalColor)
    }
    
    func resetSelectedCards() {
        // Selected first card after 3
        for id in self.selectedCardIds {
            notifier.cardUnselected(cardId: id)
        }
        
        if !isMatch() {
            selectedCardIds = Array(repeating: -1, count: 3)
            return
        }
        
        for i in 0..<3 {
            let cardId = selectedCardIds[i]
            if dealedCardCount < SetGame.totalCardCount {
                let card = deck[dealedCardCount]
                dealedCardIds[cardId] = dealedCardCount
                dealedCardCount += 1
                notifier.cardReplaced(cardId: cardId, card: card)
            } else {
                dealedCardIds[cardId] = -1
                notifier.cardRemoved(cardId: cardId)
            }
        }
        
        selectedCardIds = Array(repeating: -1, count: 3)
    }
    
    func selectCard(cardId: Int) {
        guard let nextCardSlot = selectedCardIds.index(of: -1) else {
            resetSelectedCards()
            return
        }
        
        if let selectedIndex = selectedCardIds.index(of: cardId) {
            let selectedId = selectedCardIds[selectedIndex]
            notifier.cardUnselected(cardId: selectedId)
            selectedCardIds[selectedIndex] = -1
            return
        }
        
        selectedCardIds[nextCardSlot] = cardId
        notifier.cardSelected(cardId: cardId)
        
        // Last card selected
        if nextCardSlot == 2 {
            if isMatch() {
                notifier.setMatched(cardIds: selectedCardIds)
            } else {
                notifier.setNotMatched(cardIds: selectedCardIds)
            }
        }
    }
}
