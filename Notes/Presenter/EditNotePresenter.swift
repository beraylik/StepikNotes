//
//  EditNotePresenter.swift
//  Notes
//
//  Created by Генрих Берайлик on 16/09/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit
import CoreData

protocol EditNotePresenterProtocol {
    func fillViewContent()
    func saveNoteItem(title: String, content: String, color: UIColor, expireDate: Date?)
}

class EditNotePresenter: EditNotePresenterProtocol {
    
    var note: Note?
    private var context: NSManagedObjectContext
    weak var delegate: EditNoteVCProtocol?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fillViewContent() {
        guard let note = note else { return }
        delegate?.setText(title: note.title, content: note.content)
        delegate?.setNoteColor(note.color)
        if let expireDate = note.selfDestruction {
            delegate?.setDate(expireDate)
        }
    }
    
    func saveNoteItem(title: String, content: String, color: UIColor, expireDate: Date?) {
        let newNote = Note(uid: note?.uid, title: title, content: content, importance: .normal, color: color, selfDestruction: expireDate)
        saveNote(newNote)
    }
    
    private func saveNote(_ note: Note) {
        let backendQueue = OperationQueue()
        let dbQueue = OperationQueue()
        let commonQueue = OperationQueue()
        
        let saveNoteOperation = SaveNoteOperation(
            note: note,
            context: context,
            backendQueue: backendQueue,
            dbQueue: dbQueue
        )
        commonQueue.addOperation(saveNoteOperation)
        
        let updateUI = BlockOperation { [weak self] in
            self?.delegate?.saveCompleted()
        }
        saveNoteOperation.completionBlock = {
            OperationQueue.main.addOperation(updateUI)
        }
    }
    
}
