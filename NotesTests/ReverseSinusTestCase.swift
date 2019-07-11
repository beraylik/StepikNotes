//
//  ReverseSinusTestCase.swift
//  NotesTests
//
//  Created by Миландр on 01/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import XCTest
@testable import Notes

class ReverseSinusTestCase: XCTestCase {

    func testReverseSinus() {
        let value = try! 1.0.reverseSinus()
        XCTAssertEqual(0.8414709848078965, value)
    }

    func testReverseSinus2() {
        let value = try! 1.0.reverseSinus()
        XCTAssertTrue(abs(0.8414709848078965 - value) < Double.ulpOfOne)
    }
    
    func testReverseSinusZero() {
        XCTAssertThrowsError(try 0.0.reverseSinus())
    }
    
}
