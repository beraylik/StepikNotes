//
//  NotesNetworkService.swift
//  Notes
//
//  Created by Генрих Берайлик on 10/08/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import Foundation

struct NotesNetworkService {
    
    static func loadNotes(completion: @escaping ([Note]?) -> Void) {
        GithubService.shared.loadData { (response) in
            guard let rawUrl = try? response.get().files[Gist.fileName]?.rawUrl else {
                completion(nil)
                return
            }
            GithubService.shared.loadGistFrom(url: rawUrl, completion: { (response) in
                guard let dataFromGist = try? response.get() else {
                    completion([])
                    return
                }
                guard let jsonArray = try? JSONSerialization.jsonObject(with: dataFromGist, options: []) as? [[String: Any]] else {
                    completion([])
                    return
                }
                let notes = jsonArray.compactMap({ Note.parse(json: $0) })
                completion(notes)
            })
        }
        
    }
    
    static func saveNotes(_ notes: [Note], completion: @escaping (Bool) -> Void) {
        let jsonNotes = notes.map({ $0.json })
        guard
            let dataToStore = try? JSONSerialization.data(withJSONObject: jsonNotes, options: []),
            let stringData = String(data: dataToStore, encoding: .utf8)
        else {
            completion(false)
            return
        }
        let gist = Gist(content: stringData)
        
        GithubService.shared.post(gist: gist) { (response) in
            switch response {
            case let .failure(error):
                print(error.localizedDescription)
                completion(false)
            case .success:
                completion(true)
            }
        }
    }
    
}
