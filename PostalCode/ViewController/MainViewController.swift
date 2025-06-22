//
//  MainViewController.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/06/20.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UITabBarController {
    
    private let searchTabIndex = 1

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectNavigationViewController = storyboard.instantiateViewController(identifier: "tab_select")
        let favoriteNavigationViewController = storyboard.instantiateViewController(identifier: "tab_favorite")
        let searchNavigationViewController = storyboard.instantiateViewController(identifier: "tab_search")

        if #available(iOS 18.0, *) {
            tabs = [
                UITab(title: "都道府県", image: UIImage(systemName: "list.bullet.rectangle"), identifier: "tab_select") { _ in
                    return selectNavigationViewController
                },
                UISearchTab(title: "検索", image: UIImage(systemName: "magnifyingglass"), identifier: "tab_search") { _ in
                    return searchNavigationViewController
                },
                UITab(title: "お気に入り", image: UIImage(systemName: "star"), identifier: "tab_favorite") { _ in
                    return favoriteNavigationViewController
                },
            ]
        } else {
            selectNavigationViewController.tabBarItem =
                    UITabBarItem(title: "都道府県", image: UIImage(systemName: "list.bullet.rectangle"), tag: 0)
            searchNavigationViewController.tabBarItem =
                    UITabBarItem(title: "検索", image: UIImage(systemName: "magnifyingglass"), tag: 1)
            favoriteNavigationViewController.tabBarItem =
                    UITabBarItem(title: "お気に入り", image: UIImage(systemName: "star"), tag: 2)

            self.viewControllers = [
                selectNavigationViewController,
                searchNavigationViewController,
                favoriteNavigationViewController
            ]
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSearchQuery(_:)),
            name: NSNotification.Name("handleSearchQuery"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name("handleSearchQuery"),
            object: nil
        )
    }
    
    // MARK: - SearchViewController

    @objc private func handleSearchQuery(_ notification: Notification) {
        if (getSearchViewController() != nil) {
            self.selectedIndex = searchTabIndex
            navigationController?.popToRootViewController(animated: false)

            if let query = (notification.object as? [String: Any])?["query"] as? String {
                perform(#selector(afterDelayHandleSearchQuery(_:)), with: query, afterDelay: 0.0)
            }
        }
    }

    @objc private func afterDelayHandleSearchQuery(_ query: String) {
        getSearchViewController()?.searchQuery(query)
    }
    
    private func getSearchViewController() -> SearchViewController? {
        let navigationController: BaseNavigationController?
        if #available(iOS 18.0, *) {
            navigationController = self.tabs[searchTabIndex].viewController as? BaseNavigationController
        } else {
            navigationController = self.viewControllers?[searchTabIndex] as? BaseNavigationController
        }
        return navigationController?.viewControllers.first as? SearchViewController
    }
}
