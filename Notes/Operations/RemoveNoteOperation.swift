//
//  File.swift
//  Notes
//
//  Created by Миландр on 31/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import Foundation
import CoreData

class RemoveNoteOperation: AsyncOperation {
    private let note: Note
    private let removeFromDb: RemoveNoteDBOperation
    private var saveToBackend: SaveNotesBackendOperation?
    
    private(set) var result: Bool? = false
    
    init(note: Note,
         context: NSManagedObjectContext,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue)
    {
        self.note = note
        
        removeFromDb = RemoveNoteDBOperation(note: note, context: context)
        super.init()
        
        addDependency(removeFromDb)
        dbQueue.addOperation(removeFromDb)
        
        removeFromDb.completionBlock = {
            let saveToBackend = SaveNotesBackendOperation(notes: [note])
            saveToBackend.completionBlock = {
                switch saveToBackend.result! {
                case .success:
                    self.result = true
                case .failure:
                    self.result = false
                }
                self.finish()
            }
            backendQueue.addOperation(saveToBackend)
        }
    }
    
    override func main() {
        result = removeFromDb.result
        finish()
    }
    
}
