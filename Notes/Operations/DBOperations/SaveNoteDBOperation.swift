import Foundation
import CoreData

class SaveNoteDBOperation: BaseDBOperation {
    private let note: Note
    private(set) var result: Bool = false
    
    init(note: Note,
         context: NSManagedObjectContext) {
        self.note = note
        super.init(context: context)
    }
    
    override func main() {
        var rawEntity: NoteEntity?
        
        // Check existing
        let predicate = NSPredicate(format: "uid == %@", note.uid)
        let request = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        request.predicate = predicate
        
        if let existing = try? context.fetch(request).first {
            rawEntity = existing
        } else {
            rawEntity = NSEntityDescription.insertNewObject(forEntityName: CoreDataService.shared.noteEntityName, into: context) as? NoteEntity
        }
        guard let entity = rawEntity else {
            result = false
            return
        }
        
        entity.uid = note.uid
        entity.title = note.title
        entity.content = note.content
        entity.color = note.color.hexString
        entity.importance = note.importance.rawValue
        entity.expireDate = note.selfDestruction
        do {
            try context.save()
            result = true
        } catch let error {
            result = false
            print(error.localizedDescription)
        }
        finish()
    }
}
