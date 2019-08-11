//
//  GithubService.swift
//  Notes
//
//  Created by Генрих Берайлик on 10/08/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import Foundation

class GithubService {
    
    // MARK: - Singletone instance
    
    static let shared = GithubService()
    private init() {}
    
    // MARK: - Github Keys
    
    let clientId = ""
    let clientSecret = ""
    var gitHubToken: String?
    var gistId: String?
    
    // MARK: - Network Calls
    
    func loadData(completion: @escaping (Result<Gist, Error>) -> Void) {
        guard
            let gistId = gistId,
            let url = URL(string: "https://api.github.com/gists/\(gistId)"),
            let githubToken = gitHubToken else {
                return
        }
        var request = URLRequest(url: url)
        request.addValue(githubToken, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(Result.failure(ApiError(error: .unreachable)))
                return
            }
            guard let data = data,
                let gists = try? JSONDecoder().decode(Gist.self, from: data)
                else {
                    completion(Result.failure(ApiError(error: .unreadableData)))
                    return
            }
            completion(Result.success(gists))
        }.resume()
    }
    
    func post(gist: Gist, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard
            let githubToken = gitHubToken,
            let gistId = gistId,
            let url = URL(string: "https://api.github.com/gists/\(gistId)")
        else {
                return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(githubToken)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try? JSONEncoder().encode(gist)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(Result.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(Result.failure(ApiError(error: .badStatusCode)))
                return
            }
            if response.statusCode >= 200 && response.statusCode < 300 {
                completion(Result.success(true))
            } else {
                completion(Result.failure(ApiError(error: .badStatusCode)))
            }
        }
        task.resume()
    }
    
    func loadGistFrom(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: url), let githubToken = gitHubToken else {
            completion(Result.failure(ApiError(error: .unreadableData)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(githubToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(Result.failure(ApiError(error: .unreadableData)))
                return
            }
            completion(Result.success(data))
        }
        task.resume()
    }
    
    func createStorageGist(completion: @escaping (Result<Gist, Error>) -> Void) {
        guard let url = URL(string: "https://api.github.com/gists"),
            let githubToken = gitHubToken else {
                return
        }
        let gist = Gist(content: "[]")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(githubToken)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try? JSONEncoder().encode(gist)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(Result.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(Result.failure(ApiError(error: .badStatusCode)))
                return
            }
            if response.statusCode >= 200 && response.statusCode < 300 {
                guard
                    let data = data,
                    let gist = try? JSONDecoder().decode(Gist.self, from: data)
                else {
                    completion(Result.failure(ApiError(error: .unreadableData)))
                    return
                }
                completion(Result.success(gist))
            } else {
                completion(Result.failure(ApiError(error: .badStatusCode)))
            }
        }
        task.resume()
    }
    
    func requestAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: "https://github.com/login/oauth/access_token") else { return }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: GithubService.shared.clientId),
            URLQueryItem(name: "client_secret", value: GithubService.shared.clientSecret),
            URLQueryItem(name: "code", value: code)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
    
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(Result.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(Result.failure(ApiError(error: .badStatusCode)))
                return
            }
            if response.statusCode >= 200 && response.statusCode < 300 {
                guard let data = data else { return }
                guard let authToken = try? JSONDecoder().decode(GithubAuth.self, from: data) else { return }
                completion(Result.success(authToken.getToken()))
            } else {
                completion(Result.failure(ApiError(error: .badStatusCode)))
            }
        }
        task.resume()
    }
    
}

