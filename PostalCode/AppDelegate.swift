//
//  AppDelegate.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import GoogleMobileAds
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        MobileAds.shared.start(completionHandler: nil)
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // postalcode://search?query=
        let host = url.host
        let queryItems = parseQueryString(url.query)

        if host == "search" {
            NotificationCenter.default.post(
                name: Notification.Name("handleSearchQuery"),
                object: queryItems
            )
        }
        return true
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
