//
//  RemoveNoteDBOperation.swift
//  Notes
//
//  Created by Миландр on 31/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import Foundation
import CoreData

class RemoveNoteDBOperation: BaseDBOperation {
    private let note: Note
    private(set) var result: Bool = false
    init(note: Note,
         context: NSManagedObjectContext) {
        self.note = note
        super.init(context: context)
    }
    
    override func main() {
        let predicate = NSPredicate(format: "uid == %@", note.uid)
        let request = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        request.predicate = predicate
        
        if let entity = try? context.fetch(request) {
            entity.forEach({ context.delete($0) })
        }
        
        do {
            try context.save()
            result = true
        } catch let error {
            print(error.localizedDescription)
        }

        finish()
    }
}
