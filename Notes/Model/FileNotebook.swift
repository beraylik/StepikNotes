//
//  FileNotebook.swift
//  
//
//  Created by Миландр on 21/06/2019.
//

import Foundation

class FileNotebook {
    private let filePath = "notes_storage"
    private (set) var notes = [Note]()
    
    // MARK: - Singletone instance
    static let shared = FileNotebook()
    init() {}
    
    public func add(_ note: Note) {
        let existingIndex: Int? = notes.firstIndex(where: { $0.uid == note.uid })
        if let existingIndex = existingIndex {
            notes[existingIndex] = note
        } else {
            notes.append(note)
        }
    }
    
    public func remove(with uid: String) {
        notes.removeAll(where: { $0.uid == uid })
    }
    
    public func saveToFile() {
        var path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        path.appendPathComponent(filePath, isDirectory: false)
        
        let jsonNotes = notes.map({ $0.json })
        let dataToStore = try? JSONSerialization.data(withJSONObject: jsonNotes, options: [])
        if let dataToStore = dataToStore {
            FileManager.default.createFile(atPath: path.path, contents: dataToStore, attributes: nil)
        }
    }
    
    public func loadFromFile() {
        var path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        path.appendPathComponent(filePath, isDirectory: false)
        
        guard
            let storedData = FileManager.default.contents(atPath: path.path),
            let jsonArray = try? JSONSerialization.jsonObject(with: storedData, options: []) as? [[String: Any]]
            else {
                return
        }
        notes = jsonArray.compactMap({ Note.parse(json: $0) })
    }
    
}
