//
//  NoteViewModel.swift
//  Notes
//
//  Created by Генрих Берайлик on 17/09/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit
import CoreData

final class NoteViewModel {
    
    // MARK: - Properties
    
    var title: String
    var content: String
    var expireDate: Date?
    var color: UIColor
    
    private let note: Note?
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext, note: Note?) {
        self.note = note
        self.context = context
        
        self.title = note?.title ?? ""
        self.content = note?.content ?? ""
        self.expireDate = note?.selfDestruction
        self.color = note?.color ?? .white
    }
    
    // MARK: - Closures
    
    var didSaveNote: (() -> Void)?
    
    // MARK: - Interactions
    
    func saveNote() {
        let newNote = Note(uid: note?.uid, title: title, content: content, importance: .normal, color: color, selfDestruction: expireDate)
        
        let backendQueue = OperationQueue()
        let dbQueue = OperationQueue()
        let commonQueue = OperationQueue()
        
        let saveNoteOperation = SaveNoteOperation(
            note: newNote,
            context: context,
            backendQueue: backendQueue,
            dbQueue: dbQueue
        )
        commonQueue.addOperation(saveNoteOperation)
        
        let updateUI = BlockOperation { [weak self] in
            self?.didSaveNote?()
        }
        saveNoteOperation.completionBlock = {
            OperationQueue.main.addOperation(updateUI)
        }
    }
}
