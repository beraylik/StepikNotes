//
//  Gies.swift
//  Notes
//
//  Created by Генрих Берайлик on 11/08/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import Foundation

struct GistFile: Codable {
    var filename: String
    var rawUrl: String?
    var content: String?
    
    enum CodingKeys: String, CodingKey {
        case rawUrl = "raw_url"
        case filename, content
    }
}

struct Gist: Codable {
    static let fileName = "ios-course-notes-db"
    
    var id: String?
    var description: String?
    var isPublic: Bool
    var files: [String: GistFile]
    
    enum CodingKeys: String, CodingKey {
        case isPublic = "public"
        case description, files, id
    }
    
    // MARK: - Initialization
    
    init(content: String) {
        self.description = "Notes Storage"
        self.isPublic = false
        self.files = ["ios-course-notes-db": GistFile(filename: Gist.fileName, rawUrl: nil, content: content)]
    }
    
    // MARK: - Interactions
    
    func getContent() -> String? {
        return self.files[Gist.fileName]?.content
    }
    
}
