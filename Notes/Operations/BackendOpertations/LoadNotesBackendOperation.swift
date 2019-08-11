//
//  LoadNotesBackendOperation.swift
//  Notes
//
//  Created by Миландр on 31/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import Foundation

enum LoadNotesBackendResult {
    case success([Note])
    case failure(NetworkError)
}

class LoadNotesBackendOperation: BaseBackendOperation {
    var result: LoadNotesBackendResult?
    
    override func main() {
        NotesNetworkService.loadNotes { (notes) in
            if let notes = notes {
                self.result = .success(notes)
            } else {
                self.result = .failure(.unreachable)
            }
            self.finish()
        }
    }
}
