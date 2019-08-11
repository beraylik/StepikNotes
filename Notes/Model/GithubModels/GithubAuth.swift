//
//  GithubAuth.swift
//  Notes
//
//  Created by Генрих Берайлик on 11/08/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import Foundation

struct GithubAuth: Decodable {
    var accessToken: String
    var scope: String
    var tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
    }
    
    func getToken() -> String {
        return "\(tokenType) \(accessToken)"
    }
}
