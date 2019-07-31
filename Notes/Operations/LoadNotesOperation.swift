//
//  LoadNotesOperation.swift
//  Notes
//
//  Created by Миландр on 31/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import Foundation

class LoadNotesOperation: AsyncOperation {
    private let notebook: FileNotebook
    private let loadFromDb: LoadNotesDBOperation
    private let loadFromBackend: LoadNotesBackendOperation
    private var saveToDb: SaveNoteDBOperation?
    
    private(set) var result: [Note]?
    
    init(notebook: FileNotebook, backendQueue: OperationQueue, dbQueue: OperationQueue) {
        self.notebook = notebook
        
        loadFromBackend = LoadNotesBackendOperation()
        loadFromDb = LoadNotesDBOperation(notebook: self.notebook)
        
        super.init()
        
        loadFromBackend.completionBlock = { 
            self.addDependency(self.loadFromDb)
            dbQueue.addOperation(self.loadFromDb)
        }
        
        addDependency(loadFromBackend)
        backendQueue.addOperation(loadFromBackend)
    }
    
    override func main() {
        switch loadFromBackend.result! {
        case let .success(value):
            for note in notebook.notes {
                notebook.remove(with: note.uid)
            }
            for note in value {
                notebook.add(note)
            }
            result = value
        case .failure:
            result = loadFromDb.result
        }
        finish()
    }
}
