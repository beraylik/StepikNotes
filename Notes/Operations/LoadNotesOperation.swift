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
    
    private(set) var result: [Note]?
    
    init(notebook: FileNotebook, backendQueue: OperationQueue, dbQueue: OperationQueue) {
        self.notebook = notebook
        
        loadFromBackend = LoadNotesBackendOperation()
        loadFromDb = LoadNotesDBOperation(notebook: notebook)
        
        super.init()
        
        addDependency(loadFromBackend)
        backendQueue.addOperation(loadFromBackend)
        
        addDependency(loadFromDb)
        loadFromBackend.completionBlock = { 
            dbQueue.addOperation(self.loadFromDb)
        }
        
    }
    
    override func main() {
        guard let backendStatus = loadFromBackend.result, isCancelled != true else {
            return
        }
        
        switch backendStatus {
        case let .success(value):
            notebook.replace(withNotes: value)
            result = value
        case .failure:
            result = loadFromDb.result
        }
        finish()
    }
}
