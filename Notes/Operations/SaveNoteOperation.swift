import Foundation
import CoreData

class SaveNoteOperation: AsyncOperation {
    private let saveToDb: SaveNoteDBOperation
    
    private(set) var result: Bool? = false
    
    init(note: Note,
         context: NSManagedObjectContext,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        
        saveToDb = SaveNoteDBOperation(note: note, context: context)
        super.init()
    
        addDependency(saveToDb)
        
        dbQueue.addOperation(saveToDb)
        
        self.saveToDb.completionBlock = {
            let saveToBackend = SaveNotesBackendOperation(notes: [note])
            saveToBackend.completionBlock = {
                self.finish()
            }
            
            self.addDependency(saveToBackend)
            backendQueue.addOperation(saveToBackend)
        }
        
    }
    
    override func main() {
        self.result = saveToDb.result
    }
}
