//
//  Concentration.swift
//  Concentration
//
//  Created by xcode on 12.09.2018.
//  Copyright © 2018 VSU. All rights reserved.
//

import Foundation

// [☭] More cards
// [☭] "New Game" button
// [☭] Randomize cards
// [☭] Add themes (emoji set, bg and fg colors)
// [☭] score += 2 on correct, -= 1 on wrong
// [☭] Move flip count in model
// [☭] Use Date to score

protocol CardObserver: class {
    func didOpenCard(cardNum: Int, type: Int)
    func didCloseCard(cardNum: Int)
    
    func didChangeScore(score: Int)
    func didChangeFlipCount(count: Int)
}

class Concentration {
    weak var observer: CardObserver?
    
    var turns = 0 {
        didSet {
            observer?.didChangeFlipCount(count: turns)
        }
    }
    
    var score = 0 {
        didSet {
            observer?.didChangeScore(score: score)
        }
    }
    
    var cardTypes: [Int] = []
    var openedCards: Set<Int> = []
    var wrondCardOpened = false
    let typeCount = 6
    
    let MAX_TIME = 5
    var lastCloseTime = Date.init()
    
    var selectedCardNum: Int?
    var closeTask: DispatchWorkItem?
    
    init() {
        reset()
    }
    
    func setObserver(obs: CardObserver) {
        observer = obs
    }
    
    func reset() {
        openedCards.removeAll()
        cardTypes.removeAll()
        turns = 0
        score = 0
        
        var cardCount = 0
        var selectedCount: [Int: Int] = [:] // Type -> Count
        
        while cardCount < typeCount * 2 {
            let type = Int(arc4random_uniform(UInt32(typeCount)))
            let count = selectedCount[type] ?? 0
            if count >= 2 {
                continue
            }
            
            observer?.didCloseCard(cardNum: cardTypes.count)
            
            cardTypes.append(type)
            selectedCount[type] = count + 1
            cardCount += 1
        }
        
        
        print("cards: \(cardTypes)")
    }

    func openFirstCard(_ newIndex: Int) {
        selectedCardNum = newIndex
        let type = cardTypes[newIndex]
        observer?.didOpenCard(cardNum: newIndex, type: type)
    }
    
    func openSecondCard(currentIndex: Int, newIndex: Int) {
        // Open second card
        observer?.didOpenCard(cardNum: newIndex, type: cardTypes[newIndex])
        
        selectedCardNum = nil
        // Right card opened
        if cardTypes[newIndex] == cardTypes[currentIndex] {
            let delay = -Int(lastCloseTime.timeIntervalSinceNow)
            let time_bonus = MAX_TIME - delay
            score += 2 + max(0, time_bonus)
            
            openedCards.insert(newIndex)
            openedCards.insert(currentIndex)
        } else {
            score -= 1
            
            // Wrong card opened
            closeTask = DispatchWorkItem {
                self.observer?.didCloseCard(cardNum: newIndex)
                self.observer?.didCloseCard(cardNum: currentIndex)
                self.closeTask = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: closeTask!)
        }
        lastCloseTime = Date.init()
    }
    
    func openCard(_ newIndex: Int) {
        closeTask?.perform()
        
        if selectedCardNum == nil {
            openFirstCard(newIndex)
        }
        
        let currentIndex = selectedCardNum!
        
        // Don't handle same card
        if currentIndex == newIndex {
            return
        }
        
        // Don't open card twice
        if openedCards.contains(newIndex) {
            return
        }
        
        turns += 1
        openSecondCard(currentIndex: currentIndex, newIndex: newIndex)
    }
}
