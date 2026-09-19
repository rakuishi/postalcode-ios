//
//  BaseTableViewController.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import Foundation
import UIKit

class BaseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sectionIndexColor = Color.primary

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferredContentSizeChanged(_:)),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let bannerHeight =
            (navigationController as? BaseNavigationController)?.bannerSize.height ?? 0
        guard tableView.contentInset.bottom != bannerHeight else { return }

        tableView.contentInset.bottom = bannerHeight
        tableView.verticalScrollIndicatorInsets.bottom = bannerHeight
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIContentSizeCategory.didChangeNotification,
            object: nil)
    }

    @objc func preferredContentSizeChanged(_ notification: Notification) {
        tableView.reloadData()
    }
}
