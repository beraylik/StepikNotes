//
//  Double+Extensions.swift
//  Notes
//
//  Created by Миландр on 01/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import Foundation

// MARK: - Enum for custom Errors

enum MyError: Error {
    
    case RuntimeError(message: String)
    
}

// MARK: - Double extension

extension Double {
    
    func reverseSinus() throws -> Double {
        if (abs(self) < Double.ulpOfOne) {
            throw MyError.RuntimeError(message: "Could not evaluate reverse for zero value")
        }
        
        return sin(1 / self)
    }
    
}
