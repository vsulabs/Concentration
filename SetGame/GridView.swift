//
//  GridView.swift
//  SetGame
//
//  Created by xcode on 10.10.2018.
//  Copyright © 2018 VSU. All rights reserved.
//

import UIKit

class GridView : UIView
{
    var cards = [CardView]() {
        willSet {
            for card in cards {
                card.removeFromSuperview()
            }
        }
        didSet {
            for card in cards {
                addSubview(card)
            }
            setNeedsLayout()
        }
    }
    
    static let cardPadding : CGFloat = 3.0
    static let cardAspectRatio: CGFloat = 0.7
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = Grid.Layout.aspectRatio(GridView.cardAspectRatio)
        var grid = Grid(layout: layout, frame: bounds)
        grid.cellCount = cards.count
        
        for row in 0..<grid.dimensions.rowCount {
            for column in 0..<grid.dimensions.columnCount {
                if cards.count <= (row * grid.dimensions.columnCount + column) {
                    continue
                }
                
                guard let rect = grid[row,column] else {
                    print("Can't get rect to \(row), \(column)")
                    return
                }
                
                let frame = rect.insetBy(dx: GridView.cardPadding, dy: GridView.cardPadding)
                cards[row * grid.dimensions.columnCount + column].frame = frame
            }
        }
    }
}
