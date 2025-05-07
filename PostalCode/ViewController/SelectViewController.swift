//
//  SelectViewController.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import UIKit

class SelectViewController: BaseTableViewController {

    enum SelectedAddress: Int {
        case state = 0  // 都道府県
        case cityTown = 1  // 市町村
        case street = 2  // 区群
    }

    var selectedAddress: SelectedAddress = .state
    var selectedState: String?
    var selectedCityTown: String?

    private var objects: [Any] = []
    private var sectionIndexTitles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionIndexTrackingBackgroundColor = Color.sectionIndexBackground

        if selectedAddress != .state {
            navigationItem.leftBarButtonItem = nil
        }

        (navigationController as? BaseNavigationController)?.startLoading()

        Task {
            do {
                switch selectedAddress {
                case .state:
                    let (fetchedObjects, fetchedSectionIndexTitles) = try await fetchStateData()
                    self.objects = fetchedObjects
                    self.sectionIndexTitles = fetchedSectionIndexTitles
                case .cityTown:
                    guard let selectedState = selectedState else { return }
                    let (fetchedObjects, fetchedSectionIndexTitles) = try await fetchCityTownData(
                        selectedState: selectedState)
                    self.objects = fetchedObjects
                    self.sectionIndexTitles = fetchedSectionIndexTitles
                case .street:
                    guard let selectedState = selectedState, let selectedCityTown = selectedCityTown
                    else { return }
                    let (fetchedObjects, fetchedSectionIndexTitles) = try await fetchStreetData(
                        selectedState: selectedState, selectedCityTown: selectedCityTown)
                    self.objects = fetchedObjects
                    self.sectionIndexTitles = fetchedSectionIndexTitles
                }
                (self.navigationController as? BaseNavigationController)?.stopLoading()
                self.tableView.reloadData()
            } catch {
                (self.navigationController as? BaseNavigationController)?.stopLoading()
                print("Error fetching data: \(error)")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // 「読み込み中」が表示された状態で「戻る」が押された場合に、「読み込み中」が表示され続けてしまう問題を修正
        if navigationController?.viewControllers.firstIndex(of: self) == nil {
            (navigationController as? BaseNavigationController)?.stopLoading()
        }
    }

    // MARK: - Helper Methods

    private func textLabelText(for indexPath: IndexPath) -> String {
        switch selectedAddress {
        case .state:
            return (objects[indexPath.section] as? [String])?[indexPath.row] as? String ?? ""
        case .cityTown:
            let model = objects[indexPath.section] as? PostalCodeModel
            return model?.cityTownK ?? ""
        case .street:
            let model =
                (objects[indexPath.section] as? [PostalCodeModel])?[indexPath.row]
                as? PostalCodeModel
            return model?.streetK.isEmpty ?? true ? model?.cityTownK ?? "" : model?.streetK ?? ""
        }
    }

    private func detailTextLabelText(for indexPath: IndexPath) -> String {
        switch selectedAddress {
        case .cityTown:
            let model = objects[indexPath.section] as? PostalCodeModel
            return model?.cityTownH ?? ""
        case .street:
            let model =
                (objects[indexPath.section] as? [PostalCodeModel])?[indexPath.row]
                as? PostalCodeModel
            return model?.streetK.isEmpty ?? true ? model?.cityTownH ?? "" : model?.streetH ?? ""
        default:
            return ""
        }
    }

    private func fetchStateData() async throws -> ([[String]], [String]) {
        let states = await PostalCodeRepository.shared.getStates()
        let indexTitles = await PostalCodeRepository.shared.getStateSectionIndexTitles()
        return (states, indexTitles)
    }

    private func fetchCityTownData(selectedState: String) async throws -> (
        [PostalCodeModel], [String]
    ) {
        let cityTowns = await PostalCodeRepository.shared.getCityTownsByState(selectedState)
        let indexTitles = cityTowns.map { model in
            String(model.cityTownK.prefix(3))
        }
        return (cityTowns, indexTitles)
    }

    private func fetchStreetData(selectedState: String, selectedCityTown: String) async throws -> (
        [[PostalCodeModel]], [String]
    ) {
        let streets = await PostalCodeRepository.shared.getStreetsByState(
            selectedState, byCityAndTown: selectedCityTown)
        let indexTitles = streets.map { models in
            guard let model = models.last else { return "" }
            return model.streetH.isEmpty ? "" : String(model.streetH.prefix(1))
        }
        return (streets, indexTitles)
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedAddress == .cityTown {
            return 1
        }
        return (objects[section] as? [Any])?.count ?? 0
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
        -> String?
    {
        if selectedAddress == .state {
            return sectionIndexTitles[section]
        }
        return nil
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
        switch selectedAddress {
        case .state:
            let viewController =
                storyboard?.instantiateViewController(withIdentifier: "SelectViewController")
                as! SelectViewController
            viewController.selectedAddress = .cityTown
            viewController.selectedState =
                (objects[indexPath.section] as? [String])?[indexPath.row] as? String ?? ""
            viewController.title =
                (objects[indexPath.section] as? [String])?[indexPath.row] as? String ?? ""
            navigationController?.pushViewController(viewController, animated: true)
        case .cityTown:
            let model = objects[indexPath.section] as? PostalCodeModel
            let viewController =
                storyboard?.instantiateViewController(withIdentifier: "SelectViewController")
                as! SelectViewController
            viewController.selectedAddress = .street
            viewController.selectedState = selectedState
            viewController.selectedCityTown = model?.cityTownK
            viewController.title = model?.cityTownK
            navigationController?.pushViewController(viewController, animated: true)
        case .street:
            let model =
                (objects[indexPath.section] as? [PostalCodeModel])?[indexPath.row]
                as? PostalCodeModel
            let viewController =
                storyboard?.instantiateViewController(withIdentifier: "DetailViewController")
                as! DetailViewController
            viewController.postalCodeModel = model
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
