//
//  NotesViewModel.swift
//  Notes
//
//  Created by Генрих Берайлик on 16/09/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit
import CoreData

final class NotesViewModel {
    
    // MARK: - Properties
    
    private var notes: [Note] {
        didSet {
            self.didUpdateNotes?()
        }
    }
    
    private let context: NSManagedObjectContext
 
    var notesCount: Int {
        return notes.count
    }
    
    // MARK: - Initialization
    
    init() {
        context = CoreDataService.shared.persistentContainer.newBackgroundContext()
        notes = []
    }
    
    // MARK: - Closures
    
    var didUpdateNotes: (() -> Void)?
    
    // MARK: - Interactions
    
    func saveNotes() {
        FileNotebook.shared.saveToFile()
    }
    
    func loadNotes() {
        let backendQueue = OperationQueue()
        let dbQueue = OperationQueue()
        let commonQueue = OperationQueue()
        
        let loadNotesOperation = LoadNotesOperation(
            context: context,
            backendQueue: backendQueue,
            dbQueue: dbQueue
        )
        commonQueue.addOperation(loadNotesOperation)
        
        let updateUI = BlockOperation { [weak self] in
            if let notes = loadNotesOperation.result {
                self?.notes = notes
            }
        }
        loadNotesOperation.completionBlock = {
            OperationQueue.main.addOperation(updateUI)
        }
    }
    
    func getNoteViewModel(index: Int?) -> NoteViewModel {
        if let index = index {
            return NoteViewModel(context: context, note: notes[index])
        } else {
            return NoteViewModel(context: context, note: nil)
        }   
    }
    
    func getNewNoteViewModel() -> NoteViewModel {
        return NoteViewModel(context: context, note: nil)
    }
    
    func deleteNote(index: Int) {
        let note = notes[index]
        
        let backendQueue = OperationQueue()
        let dbQueue = OperationQueue()
        let commonQueue = OperationQueue()
        
        let removeNoteOperation = RemoveNoteOperation(
            note: note,
            context: context,
            backendQueue: backendQueue,
            dbQueue: dbQueue
        )
        commonQueue.addOperation(removeNoteOperation)
        
        let updateUI = BlockOperation { [weak self] in
            self?.notes.remove(at: index)
        }
        removeNoteOperation.completionBlock = {
            OperationQueue.main.addOperation(updateUI)
        }
    }
    
}
