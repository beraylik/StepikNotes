//
//  LoadNotesDBOperation.swift
//  Notes
//
//  Created by Миландр on 31/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class LoadNotesDBOperation: BaseDBOperation {
    private(set) var result: [Note]?
    
    override func main() {
        let request = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        do {
            let notesEntities = try context.fetch(request)
            let notes = notesEntities.compactMap { (entity) -> Note? in
                guard let uid = entity.uid, let title = entity.title, let content = entity.title else {
                    return nil
                }
                let importance = Importance(rawValue: entity.importance ?? "") ?? .normal
                let color = UIColor.init(hex: entity.color ?? "")
                let note = Note(uid: uid, title: title, content: content, importance: importance, color: color, selfDestruction: entity.expireDate)
                return note
            }
            result = notes
        } catch let error {
            print(error.localizedDescription)
        }
        
        finish()
    }
}
