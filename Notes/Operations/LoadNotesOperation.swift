//
//  LoadNotesOperation.swift
//  Notes
//
//  Created by Миландр on 31/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import Foundation
import CoreData

class LoadNotesOperation: AsyncOperation {
    private let loadFromDb: LoadNotesDBOperation
    private let loadFromBackend: LoadNotesBackendOperation
    
    private(set) var result: [Note]?
    
    init(context: NSManagedObjectContext, backendQueue: OperationQueue, dbQueue: OperationQueue) {
        
        loadFromBackend = LoadNotesBackendOperation()
        loadFromDb = LoadNotesDBOperation(context: context)
        
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
//            notebook.replace(withNotes: value)
            result = value
        case .failure:
            result = loadFromDb.result
        }
        finish()
    }
}
