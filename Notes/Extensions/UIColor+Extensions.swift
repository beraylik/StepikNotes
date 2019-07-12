//
//  UIColor+Extensions.swift
//  Notes
//
//  Created by Миландр on 12/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    var hexString: String {
        var red, green, blue, alpha: CGFloat
        red = 0; green = 0; blue = 0; alpha = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = Int((red*255)) << 16  | Int((green*255)) << 8 | Int((blue*255)) << 0
        let colorString = String(format: "#%06x", rgb)
        
        return colorString
    }
    
}
