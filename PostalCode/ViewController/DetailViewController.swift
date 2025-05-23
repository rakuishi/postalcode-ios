//
//  DetailViewController.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import MessageUI
import UIKit

class DetailViewController:
    BaseTableViewController,
    @preconcurrency MFMailComposeViewControllerDelegate
{

    var postalCode: PostalCode!

    private enum Section: Int, CaseIterable {
        case info
        case action
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension

        if !postalCode.streetK.isEmpty {
            title = postalCode.streetK
        } else {
            title = postalCode.cityTownK
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int)
        -> String?
    {
        return section == Section.info.rawValue ? "項目を長押しでコピーできます。" : nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        if indexPath.section == Section.info.rawValue {
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                as! RightDetailTableViewCell
            cell.primaryLabel.text = getPrimaryLabelText(for: indexPath)
            cell.secondaryLabel.text = getSecondaryLabelText(for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "地図で確認する"
            case 1:
                cell.textLabel?.text = "メールで送信する"
            default:
                cell.textLabel?.text = "お気に入りに追加する"
            }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == Section.action.rawValue {
            switch indexPath.row {
            case 0:
                jumpMap()
            case 1:
                sendMail()
            case 2:
                addFavorite()
            default:
                break
            }
        }
    }

    override func tableView(
        _ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard indexPath.section == Section.info.rawValue else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let action = UIAction(title: "コピー", image: UIImage(systemName: "doc.on.doc")) { _ in
                if let cell = tableView.cellForRow(at: indexPath) as? RightDetailTableViewCell {
                    UIPasteboard.general.setValue(
                        cell.secondaryLabel.text ?? "", forPasteboardType: "public.utf8-plain-text")
                }
            }
            return UIMenu(title: "", children: [action])
        }
    }

    // MARK: - Helper Methods

    private func getPrimaryLabelText(for indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0: return "郵便番号"
        case 1: return "住所"
        case 2: return "読み"
        default: return ""
        }
    }

    private func getSecondaryLabelText(for indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:
            return postalCode.formattedCode
        case 1:
            return
                "\(postalCode.stateK) \(postalCode.cityTownK) \(postalCode.streetK)"
        case 2:
            return
                "\(postalCode.stateH) \(postalCode.cityTownH) \(postalCode.streetH)"
        default:
            return ""
        }
    }

    // MARK: - Actions

    private func jumpMap() {
        let query =
            "\(postalCode.stateK)\(postalCode.cityTownK)\(postalCode.streetK)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString: String
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            urlString = "comgooglemaps://?q=\(query)"
        } else {
            urlString = "http://maps.apple.com/?q=\(query)"
        }
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func sendMail() {
        guard MFMailComposeViewController.canSendMail() else { return }

        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = self

        let body = """
            郵便番号：\(postalCode.formattedCode)
            住所：\(postalCode.stateK)\(postalCode.cityTownK)\(postalCode.streetK)
            """
        viewController.setMessageBody(body, isHTML: false)
        present(viewController, animated: true, completion: nil)
    }

    private func addFavorite() {
        let isAlreadyExist = FavoriteRepository.isExist(postalCode)
        if !isAlreadyExist {
            FavoriteRepository.addFavorite(postalCode)
        }

        let address =
            "\(postalCode.stateK) \(postalCode.cityTownK) \(postalCode.streetK)"
        let message =
            isAlreadyExist
            ? "\"\(address)\"は お気に入りに登録されています"
            : "\"\(address)\"が お気に入りに登録されました"

        let alertController = UIAlertController(
            title: "確認", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - MFMailComposeViewControllerDelegate

    func mailComposeController(
        _ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        dismiss(animated: true, completion: nil)
    }
}
