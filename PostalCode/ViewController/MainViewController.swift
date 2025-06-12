//
//  MainViewController.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/06/20.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: BaseTabBarController {

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectNavigationViewController = storyboard.instantiateViewController(identifier: "tab_select")
        let favoriteNavigationViewController = storyboard.instantiateViewController(identifier: "tab_favorite")
        let searchNavigationViewController = storyboard.instantiateViewController(identifier: "tab_search")

        if #available(iOS 18.0, *) {
            tabs = [
                UITab(title: "都道府県", image: UIImage(named: "tabbar_select"), identifier: "tab_select") { _ in
                    return selectNavigationViewController
                },
                UISearchTab(title: "検索", image: UIImage(named: "tabbar_search"), identifier: "tab_search") { _ in
                    return searchNavigationViewController
                },
                UITab(title: "お気に入り", image: UIImage(named: "tabbar_star"), identifier: "tab_favorite") { _ in
                    return favoriteNavigationViewController
                },
            ]
        } else {
            selectNavigationViewController.tabBarItem =
                    UITabBarItem(title: "都道府県", image: UIImage(named: "tabbar_select"), tag: 0)
            favoriteNavigationViewController.tabBarItem =
                    UITabBarItem(title: "お気に入り", image: UIImage(named: "tabbar_star"), tag: 1)
            searchNavigationViewController.tabBarItem =
                    UITabBarItem(title: "検索", image: UIImage(named: "tabbar_search"), tag: 2)

            self.viewControllers = [
                selectNavigationViewController,
                searchNavigationViewController,
                favoriteNavigationViewController
            ]
        }
    }
}
