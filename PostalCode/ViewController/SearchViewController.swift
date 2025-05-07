//
//  SearchViewController.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import UIKit

class SearchViewController: BaseTableViewController, UISearchBarDelegate {

    private var searchBar: UISearchBar!
    private var objects: [[PostalCodeModel]] = []
    private var sectionIndexTitles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
        tableView.sectionIndexTrackingBackgroundColor = Color.sectionIndexBackground

        searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = self
        searchBar.placeholder = "1600000, 新宿区"
        searchBar.searchBarStyle = .default
        searchBar.tintColor = Color.primary
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.font = UIFont.systemFont(ofSize: 16)
            textField.backgroundColor = Color.searchFieldBackground
        }

        navigationItem.titleView = searchBar
        title = "検索"
    }

    // MARK: - UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchQuery(searchBar.text ?? "")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            objects = []
            sectionIndexTitles = []
            tableView.reloadData()
        }
    }

    // MARK: - Search Logic

    func searchQuery(_ query: String) {
        searchBar.text = query

        // 郵便番号のハイフンを消去
        let sanitizedQuery = query.replacingOccurrences(of: "-", with: "")
        (navigationController as? BaseNavigationController)?.startLoading()

        Task {
            let results = await performSearch(with: sanitizedQuery)

            // テーブルビュー右側のセクションインデックスを作成する
            let indexTitles = results.map { models in
                let model = models.first
                return self.stringToThreeCharacters(model?.stateK ?? "")
            }

            self.objects = results
            self.sectionIndexTitles = indexTitles
            (self.navigationController as? BaseNavigationController)?.stopLoading()
            self.tableView.reloadData()
        }
    }

    private func performSearch(with query: String) async -> [[PostalCodeModel]] {
        return await PostalCodeRepository.shared.searchWithQuery(query)
    }

    private func stringToThreeCharacters(_ string: String) -> String {
        return String(string.prefix(3))
    }

    private func textLabelText(for indexPath: IndexPath) -> String {
        let model = objects[indexPath.section][indexPath.row]
        return "\(model.stateK) \(model.cityTownK) \(model.streetK)"
    }

    private func detailTextLabelText(for indexPath: IndexPath) -> String {
        let model = objects[indexPath.section][indexPath.row]
        let postalCode = model.postalCode
        let formattedPostalCode =
            "\(postalCode.prefix(3))-\(postalCode.suffix(postalCode.count - 3))"
        return formattedPostalCode
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects[section].count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
        -> String?
    {
        return sectionIndexTitles[section]
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = textLabelText(for: indexPath)
        cell.detailTextLabel?.text = detailTextLabelText(for: indexPath)
        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = objects[indexPath.section][indexPath.row]

        let viewController =
            storyboard?.instantiateViewController(withIdentifier: "DetailViewController")
            as! DetailViewController
        viewController.postalCodeModel = model
        navigationController?.pushViewController(viewController, animated: true)
    }
}
