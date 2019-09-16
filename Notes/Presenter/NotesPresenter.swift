//
//  AuthPresenter.swift
//  Notes
//
//  Created by Генрих Берайлик on 16/09/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit
import CoreData

typealias NotePresenter = (title: String, content: String, color: UIColor)

protocol NotesPresenterProtocol {
    
    func setVCDelegate(_ delegate: NotesVCProtocol)
    func editNoteVC(index: Int?) -> UIViewController?
    
    func loadNotes()
    func saveNotes()
    func getNotesCount() -> Int
    func getNotePresenter(at index: Int) -> NotePresenter
    func deleteNote(index: Int)
}

final class NotesPresenter: NotesPresenterProtocol {
    
    weak var delegate: NotesVCProtocol?
    
    private let context: NSManagedObjectContext
    private var notes = [Note]()
    
    init() {
        context = CoreDataService.shared.persistentContainer.newBackgroundContext()
    }
    
    func setVCDelegate(_ delegate: NotesVCProtocol) {
        self.delegate = delegate
    }
    
    func getNotesCount() -> Int {
        return notes.count
    }
    
    func editNoteVC(index: Int?) -> UIViewController? {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        guard let editView = storyboard.instantiateViewController(withIdentifier: "EditNoteViewController") as? EditNoteViewController else { return nil }
        
        let editPresenter = EditNotePresenter(context: self.context)
        if let index = index {
            editPresenter.note = notes[index]
        }
        editView.presenter = editPresenter
        editPresenter.delegate = editView
        
        return editView
    }
    
    func getNotePresenter(at index: Int) -> NotePresenter {
        let note = notes[index]
        return (note.title, note.content, note.color)
    }
    
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
                self?.delegate?.updateContent()
            }
        }
        loadNotesOperation.completionBlock = {
            OperationQueue.main.addOperation(updateUI)
        }
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
            self?.delegate?.removeRow(index: index)
            // TODO: Remove from VC
        }
        removeNoteOperation.completionBlock = {
            OperationQueue.main.addOperation(updateUI)
        }
    }
    
}
