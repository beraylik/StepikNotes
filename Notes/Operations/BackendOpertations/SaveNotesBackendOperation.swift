import Foundation

enum SaveNotesBackendResult {
    case success
    case failure(NetworkError)
}

class SaveNotesBackendOperation: BaseBackendOperation {
    var result: SaveNotesBackendResult?
    var notes: [Note]
    
    init(notes: [Note]) {
        self.notes = notes
        super.init()
    }
    
    override func main() {
        result = .failure(.unreachable)
        self.finish()
        
//        NotesNetworkService.saveNotes(notes) { (isSaved) in
//            if isSaved {
//                self.result = .success
//            } else {
//                self.result = .failure(.unreachable)
//            }
//            self.finish()
//        }
    }
}
