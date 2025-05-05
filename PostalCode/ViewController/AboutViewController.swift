//
//  AboutViewController.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

@objcMembers
class AboutViewController: UITableViewController, @preconcurrency MFMailComposeViewControllerDelegate {

    private enum Section: Int, CaseIterable {
        case about
        case feedback
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .about:
            return 4
        case .feedback:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Section.about.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "バージョン"
                cell.detailTextLabel?.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                cell.accessoryType = .none
                cell.selectionStyle = .none
            case 1:
                cell.textLabel?.text = "郵便番号データ"
                cell.detailTextLabel?.text = "2024年8月30日"
                cell.accessoryType = .none
                cell.selectionStyle = .none
            case 2:
                cell.textLabel?.text = "開発"
                cell.detailTextLabel?.text = "rakuishi"
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            case 3:
                cell.textLabel?.text = "プライバシーポリシー"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            default:
                break
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == Section.about.rawValue {
            if indexPath.row == 2 {
                if let url = URL(string: "https://rakuishi.com") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else if indexPath.row == 3 {
                if let url = URL(string: "https://rakuishi.github.io/privacy-policy/postalcode.html") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } else if indexPath.section == Section.feedback.rawValue {
            sendFeedback()
        }
    }

    // MARK: - Feedback

    private func sendFeedback() {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let composeViewController = MFMailComposeViewController()
        composeViewController.mailComposeDelegate = self
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        var body = "\n\n\n"
        body += "Device: \(platform())\n"
        body += "iOS: \(UIDevice.current.systemVersion)\n"
        body += "App: 郵便番号検索くん \(version)"
        
        composeViewController.setMessageBody(body, isHTML: false)
        composeViewController.setSubject("[郵便番号検索くん Feedback]")
        composeViewController.setToRecipients(["rakuishi@gmail.com"])
        
        present(composeViewController, animated: true, completion: nil)
    }

    private func platform() -> String {
        var size: Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    // MARK: - MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Actions

    @IBAction func dismissViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
