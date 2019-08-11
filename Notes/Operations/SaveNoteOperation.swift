import Foundation

class SaveNoteOperation: AsyncOperation {
    private let saveToDb: SaveNoteDBOperation
    
    private(set) var result: Bool? = false
    
    init(note: Note,
         notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        
        saveToDb = SaveNoteDBOperation(note: note, notebook: notebook)
        
        super.init()
    
        addDependency(saveToDb)
        
        dbQueue.addOperation(saveToDb)
        
        self.saveToDb.completionBlock = {
            let saveToBackend = SaveNotesBackendOperation(notes: self.saveToDb.notebook.notes)
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
