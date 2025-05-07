//
//  FavoriteViewController.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import UIKit

class FavoriteViewController: BaseTableViewController {

    private var postalCodes: [PostalCodeModel] = []
    private var deleteButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension

        deleteButtonItem = UIBarButtonItem(
            title: "消去", style: .plain, target: self, action: #selector(deleteAllData))
        navigationItem.leftBarButtonItem = deleteButtonItem

        reloadAllData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let hasSelectedRow = tableView.indexPathForSelectedRow != nil

        if !hasSelectedRow {
            reloadAllData()
        }

        deleteButtonItem.isEnabled = !postalCodes.isEmpty
    }

    // MARK: - Data Handling

    private func reloadAllData() {
        postalCodes = FavoriteRepository.getFavorites()
        tableView.reloadData()
    }

    @objc private func deleteAllData() {
        let alertController = UIAlertController(
            title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(
            UIAlertAction(title: "すべての項目を削除", style: .destructive) { _ in
                FavoriteRepository.deleteAllFavorite()
                self.reloadAllData()
                self.deleteButtonItem.isEnabled = false
            })

        alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    private func textLabelText(for model: PostalCodeModel) -> String {
        return "\(model.stateK) \(model.cityTownK) \(model.streetK)"
    }

    private func detailTextLabelText(for model: PostalCodeModel) -> String {
        let postalCode = model.postalCode
        let formattedPostalCode =
            "\(postalCode.prefix(3))-\(postalCode.suffix(postalCode.count - 3))"
        return formattedPostalCode
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postalCodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let postalCode = self.postalCodes[indexPath.row]

        cell.textLabel?.text = textLabelText(for: postalCode)
        cell.detailTextLabel?.text = detailTextLabelText(for: postalCode)

        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(
        _ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            tableView.beginUpdates()

            FavoriteRepository.deleteFavoritePostalCodeModel(at: indexPath.row)
            postalCodes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)

            tableView.endUpdates()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postalCode = self.postalCodes[indexPath.row]

        let viewController =
            storyboard?.instantiateViewController(withIdentifier: "DetailViewController")
            as! DetailViewController
        viewController.postalCodeModel = postalCode
        navigationController?.pushViewController(viewController, animated: true)
    }
}
