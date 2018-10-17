//
//  CardView.swift
//  SetGame
//
//  Created by xcode on 10.10.2018.
//  Copyright © 2018 VSU. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    var faceBackgroundColor: UIColor = UIColor.white { didSet { setNeedsDisplay()} }
    
    var isSelected:Bool = false { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var isMatched: Bool? { didSet { setNeedsDisplay(); setNeedsLayout() } }

    var count: Int = 1 {
        didSet {setNeedsDisplay();   setNeedsLayout()}
    }
    private var color = UIColor.red {
        didSet { setNeedsDisplay(); setNeedsLayout()}
    }
    private var fill = Fill.Striped {
        didSet { setNeedsDisplay(); setNeedsLayout()}
    }
    private var figure = Figure.Squiggle {
        didSet { setNeedsDisplay(); setNeedsLayout()}
    }

    static func getUIColorFromColor(_ color: Color) -> UIColor {
        switch(color) {
        case .Red:
            return UIColor.red
        case .Green:
            return UIColor.green
        case .Blue:
            return UIColor.blue
        }
    }
    
    init(_ card: Card) {
        super.init(frame: UIScreen.main.bounds);
        
        figure = card.figure
        fill = card.fill
        color = CardView.getUIColorFromColor(card.color)
        count =  card.count
        isSelected = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        UIRectFill(bounds)
        
        drawPictures()
    }
    
    private func getOrigin() -> CGPoint {
        switch count {
        case 1:
            return CGPoint(x: cardRect.minX, y: cardRect.midY - pictureHeight / 2)
        case 2:
            return CGPoint(x: cardRect.minX, y: cardRect.midY - interPictureHeight / 2 - pictureHeight)
        case 3:
            return CGPoint (x: cardRect.minX, y: cardRect.minY)
        default:
            return CGPoint (x: 0, y: 0)
        }
    }
    
    private func drawPictures(){
        color.setFill()
        color.setStroke()
        
        let origin = getOrigin()
        let size = CGSize(width: cardRect.width, height: pictureHeight)
        var rect = CGRect(origin: origin, size: size)
        for _ in 0..<count {
            drawShape(pos: rect)
            rect = rect.offsetBy(dx: 0, dy: pictureHeight + interPictureHeight)
        }
    }
    
    private func drawShape(pos rect: CGRect) {
        let path: UIBezierPath
        switch figure {
        case .Diamond:
            path = pathForDiamond(in: rect)
        case .Oval:
            path = ovalPath(in: rect)
        case .Squiggle:
            path = squigglePath(in: rect)
        }
        
        path.lineWidth = 3.0
        path.stroke()
        switch fill {
        case .Solid:
            path.fill()
        case .Striped:
            stripeShape(path: path, in: rect)
        default:
            break
        }
    }
    
    private func stripeShape(path: UIBezierPath, in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        path.addClip()
        stripeRect(rect)
        context?.restoreGState()
    }
    
    private func squigglePath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        
        let dx = rect.width * 0.5;
        let dy = rect.height * 0.5;
        
        let dsqx = dx * 0.5;
        let dsqy = dy * 0.5;
        let point = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: CGPoint(x: point.x - dx, y: point.y))
        
        path.addQuadCurve(to: CGPoint(x: point.x - dsqx, y: point.y + dsqy),
                          controlPoint: CGPoint(x: point.x - dx, y: point.y + dy + dsqy))
        path.addQuadCurve(to: CGPoint(x: point.x - dsqx, y: point.y + dsqy),
                          controlPoint: CGPoint(x: point.x - dx, y: point.y + dy + dsqy))
        
        path.addCurve(to: CGPoint(x: point.x + dx, y: point.y),
                      controlPoint1: point,
                      controlPoint2: CGPoint(x: point.x + dx, y: point.y + dy * 2))
        path.addQuadCurve(to: CGPoint(x: point.x + dsqx, y: point.y - dsqy),
                          controlPoint: CGPoint(x: point.x + dx, y: point.y - dy - dsqy))
        path.addCurve(to: CGPoint(x: point.x - dx, y: point.y),
                      controlPoint1: point,
                      controlPoint2: CGPoint(x: point.x - dx, y: point.y - dy * 2))
        path.close()
        
        return path
    }
    
    private func ovalPath(in rect: CGRect) -> UIBezierPath {
        return UIBezierPath(ovalIn: rect)
    }
    
    private func pathForDiamond(in rect: CGRect) -> UIBezierPath {
        let diamond = UIBezierPath()

        let offset = CGPoint(x: rect.width / 8, y: rect.height / 4)
        let squashedWidthOffset = (rect.width - 2 * offset.x) / 3.5
        
        diamond.move(to: CGPoint(x: rect.minX + offset.x , y: rect.midY - offset.y))
        diamond.addLine(to: CGPoint(x: rect.midX - squashedWidthOffset, y: rect.minY))
        diamond.addLine(to: CGPoint(x: rect.midX + squashedWidthOffset, y: rect.minY))
        diamond.addLine(to: CGPoint(x: rect.maxX - offset.x, y: rect.midY - offset.y))
        diamond.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        diamond.close()
        
        return diamond
    }
    
    private func stripeRect(_ rect: CGRect) {
        let stripe = UIBezierPath()
        stripe.move(to: CGPoint(x: rect.minX, y: bounds.minY ))
        stripe.addLine(to: CGPoint(x: rect.minX, y: bounds.maxY))
        
        let interStripeSpace: CGFloat = 5.0
        let stripeCount = Int(cardRect.width / interStripeSpace)
        for _ in 1...stripeCount {
            let translation = CGAffineTransform(translationX: interStripeSpace, y: 0)
            stripe.apply(translation)
            stripe.stroke()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.borderWidth = 5.0
        layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        if isSelected {
            layer.borderColor = #colorLiteral(red: 1, green: 0.8781439489, blue: 0.335140321, alpha: 1)
        }
        if let matched = isMatched {
            if matched {
                layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0.07474343349, alpha: 1)
            } else {
                layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            }
        }
    }

    private var maxCardRect: CGRect {
        let scale: CGFloat = 3.0 / 4.0
        let width = bounds.width * scale
        let height = bounds.height * scale
        return bounds.insetBy(dx: (bounds.width - width) / 2,
                              dy: (bounds.height - height) / 2)
    }
    
    private var cardRect: CGRect {
        let width = maxCardRect.height * 0.6
        return maxCardRect.insetBy(dx: (maxCardRect.width - width) / 2, dy: 0)
    }
    
    private var pictureHeight: CGFloat {
        return cardRect.height / 4
    }
    
    private var interPictureHeight: CGFloat {
        return (cardRect.height - (3 * pictureHeight)) / 2
    }
}

