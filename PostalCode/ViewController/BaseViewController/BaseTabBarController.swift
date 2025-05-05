//
//  BaseTabBarController.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import UIKit

@objcMembers
class BaseTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSearchQuery(_:)),
                                               name: NSNotification.Name("handleSearchQuery"),
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name("handleSearchQuery"),
                                                  object: nil)
    }

    // MARK: - SearchViewController

    @objc private func handleSearchQuery(_ notification: Notification) {
        self.selectedIndex = 1

        guard let navigationController = self.viewControllers?[self.selectedIndex] as? BaseNavigationController else {
            return
        }

        navigationController.popToRootViewController(animated: false)

        if let query = (notification.object as? [String: Any])?["query"] as? String {
            perform(#selector(afterDelayHandleSearchQuery(_:)), with: query, afterDelay: 0.0)
        }
    }

    @objc private func afterDelayHandleSearchQuery(_ query: String) {
        guard let navigationController = self.viewControllers?[1] as? BaseNavigationController,
              let searchViewController = navigationController.viewControllers.first as? SearchViewController else {
            return
        }

        searchViewController.searchQuery(query)
    }
}
