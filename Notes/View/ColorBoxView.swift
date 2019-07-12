//
//  ColorBoxView.swift
//  Notes
//
//  Created by Миландр on 12/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit

@IBDesignable
class ColorBoxView: UIView {
    
    @IBInspectable
    var borderWidth: CGFloat = 3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = .black  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var isSelected: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        
        drawSelectedState()
    }
    
    private var curPath: UIBezierPath?
    private func drawSelectedState() {
        if isSelected {
            UIColor(red: 142/255, green: 0, blue: 1/255, alpha: 1).setFill()
            let markerSize = frame.size.applying(CGAffineTransform.init(scaleX: 1/2.5, y: 1/2.5))
            
            let path = getTrianglePath(in: CGRect(
                origin: CGPoint(x: bounds.maxX - markerSize.width - 4, y: bounds.minY + 4),
                size: markerSize
            ))
            
            path.fill()
            curPath = path
        } else {
            curPath = nil
        }
    }
    
    private func getTrianglePath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = 0.5

        //Calculate Radius of Arcs using Pythagoras
        let sideOne = rect.width * 0.4
        let sideTwo = rect.height * 0.3
        let arcRadius = sqrt(sideOne*sideOne + sideTwo*sideTwo)/2
        
        //Left Hand Curve
        let leftCenter = CGPoint(x: rect.width * 0.3 + rect.minX, y: rect.height * 0.35 + rect.minY)
        path.addArc(withCenter: leftCenter, radius: arcRadius, startAngle: 135.degreesToRadians, endAngle: 315.degreesToRadians, clockwise: true)
        
        //Top Centre Dip
        path.addLine(to: CGPoint(x: rect.width/2 + rect.minX, y: rect.height * 0.2 + rect.minY))
        
        //Right Hand Curve
        let rightCenter = CGPoint(x: rect.width * 0.7 + rect.minX, y: rect.height * 0.35 + rect.minY)
        path.addArc(withCenter: rightCenter, radius: arcRadius, startAngle: 225.degreesToRadians, endAngle: 45.degreesToRadians, clockwise: true)
        
        //Right Bottom Line
        path.addLine(to: CGPoint(x: rect.width * 0.5 + rect.minX, y: rect.height * 0.95))
        
        //Left Bottom Line
        path.close()
        path.stroke()
        
        return path
    }
    
}
