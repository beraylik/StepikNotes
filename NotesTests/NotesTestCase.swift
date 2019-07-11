//
//  NotesTestCase.swift
//  NotesTests
//
//  Created by Миландр on 01/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import XCTest
@testable import Notes

class NotesTestCase: XCTestCase {

    func testUid() {
        // if uid is not set
        let note1 = Note(uid: nil, title: "title", content: "content", importance: .normal)
        XCTAssertNotNil(UUID(uuidString: note1.uid))
        
        // if uid is set
        let note2 = Note(uid: "12345", title: "tetris", content: "content", importance: .normal)
        XCTAssertEqual(note2.uid, "12345")
    }
    
    func testColors() {
        // if default is White
        let note1 = Note(uid: nil, title: "title", content: "content", importance: .normal)
        XCTAssertEqual(note1.color, UIColor.white)
        
        // if new color is saved
        let note2 = Note(uid: nil, title: "title", content: "title", importance: .important, color: .blue, selfDestruction: nil)
        XCTAssertEqual(note2.color, UIColor.blue)
    }

    func testSelfDestruction() {
        let date = Date()
        
        // if SelfDescruction is not set
        let note1 = Note(uid: nil, title: "title", content: "content", importance: .normal)
        XCTAssertEqual(note1.selfDestruction, nil)
        
        // if SelfDescruction is set
        let note2 = Note(uid: nil, title: "title", content: "title", importance: .important, color: .blue, selfDestruction: date)
        XCTAssertEqual(note2.selfDestruction, date)
    }
    
}
