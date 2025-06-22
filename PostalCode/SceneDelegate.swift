//
//  SceneDelegate.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/06/22.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let mainViewController = MainViewController()
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }

        let host = url.host
        let queryItems = parseQueryString(url.query)

        if host == "search" {
            NotificationCenter.default.post(
                name: Notification.Name("handleSearchQuery"),
                object: queryItems
            )
        }
    }
    
    private func parseQueryString(_ query: String?) -> [String: String] {
        guard let query = query else { return [:] }
        var dict: [String: String] = [:]
        let pairs = query.components(separatedBy: "&")
        for pair in pairs {
            let elements = pair.components(separatedBy: "=")
            if let key = elements.first?.removingPercentEncoding,
                let value = elements.last?.removingPercentEncoding
            {
                dict[key] = value
            }
        }
        return dict
    }
}
