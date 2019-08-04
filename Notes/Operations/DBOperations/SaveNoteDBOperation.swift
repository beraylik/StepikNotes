import Foundation

class SaveNoteDBOperation: BaseDBOperation {
    private let note: Note
    private(set) var result: Bool = false
    
    init(note: Note,
         notebook: FileNotebook) {
        self.note = note
        super.init(notebook: notebook)
    }
    
    override func main() {
        notebook.add(note)
        notebook.saveToFile()
        result = true
        finish()
    }
}
