//
//  GithubAuthVC.swift
//  Notes
//
//  Created by Генрих Берайлик on 10/08/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit
import WebKit

protocol AuthViewControllerDelegate: class {
    func handleTokenChanged(token: String)
    func finishedAuth(successful: Bool)
}

class AuthViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let webView = WKWebView()
    private let scheme = "mygists" // схема для callback
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        guard let request = authGetRequest else { return }
        webView.load(request)
        webView.navigationDelegate = self
    }
    
    // MARK: - Interactions
    
    private var authGetRequest: URLRequest? {
        guard var urlComponents = URLComponents(string: "https://github.com/login/oauth/authorize") else { return nil }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: "\(GithubService.shared.clientId)"),
            URLQueryItem(name: "scope", value: "gist")
        ]
        
        guard let url = urlComponents.url else { return nil }
        
        return URLRequest(url: url)
    }
    
    // MARK: - Configure UI
    
    private func setupViews() {
        view.backgroundColor = .white
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}

// MARK: - WebKit Navigation Delegate

extension AuthViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        defer {
            decisionHandler(.allow)
        }
        if let url = navigationAction.request.url, url.scheme == scheme {
            defer {
                dismiss(animated: true, completion: nil)
            }
            let targetString = url.absoluteString.replacingOccurrences(of: "#", with: "?")
            guard let components = URLComponents(string: targetString) else { return }
            guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else { return }
            
            GithubService.shared.requestAuthToken(code: code) { (result) in
                guard let token = try? result.get() else {
                    self.delegate?.finishedAuth(successful: false)
                    return
                }
                self.delegate?.handleTokenChanged(token: token)
                print(token)
                
                GithubService.shared.createStorageGist(completion: { (result) in
                    GithubService.shared.gistId = try? result.get().id
                    self.delegate?.finishedAuth(successful: true)
                    DispatchQueue.main.async {
                        return
                    }
                })
            }
        }
        
    }
}


