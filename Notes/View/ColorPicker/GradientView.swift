//
//  GradientView.swift
//  Notes
//
//  Created by Генрих Берайлик on 14/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    // MARK: - Properties
    
    var colorDragHandler: ((UIColor) -> Void)?
    var targetColor: UIColor = .white
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Interactions
    
    func updateBrightness(_ value: CGFloat) {
        let aimOffset = aimLayer.bounds.height/2
        var percent = value > 1 ? 1 : value
        percent = value < 0 ? 0 : value
        
        let currPoint = aimLayer.frame.origin
        let newY = (bounds.maxY-aimOffset) - bounds.midY * percent
        let newPoint = CGPoint(x: currPoint.x, y: newY+aimOffset)
        
        aimLayer.frame.origin = CGPoint(x: newPoint.x, y: newPoint.y-aimOffset)
        let color = getColorAtPoint(point: newPoint)
        colorDragHandler?(color)
    }
    
    private func moveAimLayer(point: CGPoint) {
        guard
            point.x >= bounds.minX, point.x <= bounds.maxX,
            point.y >= bounds.minY, point.y <= bounds.maxY
            else {
                return
        }
        let newPoint = CGPoint(
            x: point.x - aimLayer.frame.width/2,
            y: point.y - aimLayer.frame.height/2
        )
        
        aimLayer.frame.origin = newPoint
        let color = getColorAtPoint(point: newPoint)
        colorDragHandler?(color)
    }
    
    private func getColorAtPoint(point:CGPoint) -> UIColor {
        let saturationExponentTop: Float = 1
        let saturationExponentBottom: Float = 0

        let roundedPoint = CGPoint(x: CGFloat(Int(point.x)),
                                   y: CGFloat(Int(point.y)))
        var saturation = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(2 * roundedPoint.y) / self.bounds.height
            : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        saturation = CGFloat(powf(Float(saturation), roundedPoint.y < self.bounds.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
        let brightness = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        let hue = roundedPoint.x / self.bounds.width
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    private func getPointForColor(color:UIColor) -> CGPoint {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil);
        
        var yPos:CGFloat = 0
        let halfHeight = (self.bounds.height / 2)
        if (brightness >= 0.99) {
            let percentageY = powf(Float(saturation), 1.0)
            yPos = CGFloat(percentageY) * halfHeight
        } else {
            //use brightness to get Y
            yPos = halfHeight + halfHeight * (1.0 - brightness)
        }
        let xPos = hue * self.bounds.width
        return CGPoint(x: xPos, y: yPos)
    }
    
    // MARK: - Configure UI
    
    private func setupView() {
        self.clipsToBounds = true
        
        self.layer.addSublayer(gradientLayer)
        self.layer.addSublayer(brightnessLayer)
        self.layer.addSublayer(aimLayer)
    }
    
    // MARK: - View Lifecycle
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let point = getPointForColor(color: targetColor)
        moveAimLayer(point: point)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        brightnessLayer.frame = bounds
    }
    
    // MARK: - Touches handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            moveAimLayer(point: point)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            moveAimLayer(point: point)
        }
    }
    
    // MARK: - CALayers
    
    private let aimLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 30, height: 30), cornerRadius: 15).cgPath
        layer.frame.size = CGSize(width: 30, height: 30)
        layer.strokeColor = UIColor.gray.cgColor
        layer.lineWidth = 4
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let rainbow: [UIColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .red]
        let layer = CAGradientLayer()
        layer.colors = rainbow.map({ $0.cgColor })
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()
    
    private lazy var brightnessLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.white.cgColor,
                                 UIColor.clear.cgColor,
                                 UIColor.black.cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()
}
