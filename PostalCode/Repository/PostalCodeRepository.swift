//
//  PostalCodeRepository.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/06.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import Foundation
import SQLite3

actor PostalCodeRepository {

    // MARK: - Properties

    // AboutViewController の「郵便番号データ」の日付を変えるのを忘れないように
    private static let databaseName = "data_202408"

    static let shared = PostalCodeRepository()
    private let databasePath: String
    private var database: OpaquePointer?

    // MARK: - Initializer

    private init() {
        let temporaryDirectory = NSTemporaryDirectory()
        databasePath = (temporaryDirectory as NSString).appendingPathComponent("\(Self.databaseName).sqlite")

        setupDatabase()
    }

    // MARK: - Private Methods
    
    private nonisolated func setupDatabase() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: databasePath) {
            if let defaultDatabasePath = Bundle.main.path(
                forResource: Self.databaseName, ofType: "sqlite")
            {
                do {
                    try fileManager.copyItem(atPath: defaultDatabasePath, toPath: databasePath)
                } catch {
                    print("Error copying database: \(error)")
                }
            }
        }
    }

    // MARK: - Class Methods

    static func path() -> String {
        let temporaryDirectory = NSTemporaryDirectory()
        return (temporaryDirectory as NSString).appendingPathComponent("\(databaseName).sqlite")
    }

    // MARK: - Instance Methods

    func searchWithQuery(_ query: String) -> [[PostalCodeModel]] {
        var sanitizedQuery = query
        sanitizedQuery = sanitizedQuery.replacingOccurrences(of: "都", with: "都 ")
        sanitizedQuery = sanitizedQuery.replacingOccurrences(of: "道", with: "道 ")
        sanitizedQuery = sanitizedQuery.replacingOccurrences(of: "府", with: "府 ")
        sanitizedQuery = sanitizedQuery.replacingOccurrences(of: "県", with: "県 ")
        sanitizedQuery = sanitizedQuery.replacingOccurrences(of: "市", with: "市 ")
        sanitizedQuery = sanitizedQuery.replacingOccurrences(of: "町", with: "町 ")
        sanitizedQuery = sanitizedQuery.replacingOccurrences(of: "村", with: "村 ")
        sanitizedQuery = sanitizedQuery.replacingOccurrences(of: "区", with: "区 ")
        sanitizedQuery = sanitizedQuery.replacingOccurrences(of: "郡", with: "郡 ")

        let queryComponents = sanitizedQuery.split(separator: " ").map { String($0) }
        guard let firstQuery = queryComponents.first else { return [] }

        guard openDatabase() != nil else { return [] }
        defer { closeDatabase() }

        let sql = """
            SELECT * FROM data WHERE
            postal_code LIKE ? OR
            state_h LIKE ? OR
            city_town_h LIKE ? OR
            street_h LIKE ? OR
            state_k LIKE ? OR
            city_town_k LIKE ? OR
            street_k LIKE ?
            """
        guard let statement = prepareStatement(sql: sql) else { return [] }
        defer { finalizeStatement(statement) }

        for index in 1...7 {
            let likeQuery = "%\(firstQuery)%"
            sqlite3_bind_text(statement, Int32(index), (likeQuery as NSString).utf8String, -1, nil)
        }

        var results: [PostalCodeModel] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            let model = PostalCodeModel()
            model.postalCode = String(cString: sqlite3_column_text(statement, 0))
            model.stateH = String(cString: sqlite3_column_text(statement, 1))
            model.cityTownH = String(cString: sqlite3_column_text(statement, 2))
            model.streetH = String(cString: sqlite3_column_text(statement, 3))
            model.stateK = String(cString: sqlite3_column_text(statement, 4))
            model.cityTownK = String(cString: sqlite3_column_text(statement, 5))
            model.streetK = String(cString: sqlite3_column_text(statement, 6))
            results.append(model)
        }

        // 絞り込み検索
        var filteredResults = results
        for query in queryComponents.dropFirst() {
            filteredResults = filteredResults.filter { model in
                model.postalCode.contains(query) || model.stateH.contains(query)
                    || model.cityTownH.contains(query) || model.streetH.contains(query)
                    || model.stateK.contains(query) || model.cityTownK.contains(query)
                    || model.streetK.contains(query)
            }
        }

        return divideByState(with: filteredResults)
    }

    func getStateSectionIndexTitles() -> [String] {
        return ["北海道", "東北", "関東", "中部", "近畿", "中国", "四国", "九州"]
    }

    func getStates() -> [[String]] {
        return [
            ["北海道"],
            ["青森県", "岩手県", "秋田県", "宮城県", "山形県", "福島県"],
            ["茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県"],
            ["新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県"],
            ["三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県"],
            ["鳥取県", "島根県", "岡山県", "広島県", "山口県"],
            ["徳島県", "香川県", "愛媛県", "高知県"],
            ["福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"],
        ]
    }

    func getCityTownsByState(_ state: String) -> [PostalCodeModel] {
        guard openDatabase() != nil else { return [] }
        defer { closeDatabase() }

        let sql = "SELECT * FROM data WHERE state_k LIKE ?"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(self.database, sql, -1, &statement, nil) == SQLITE_OK else {
            return []
        }
        defer { finalizeStatement(statement) }

        let likeQuery = "%\(state)%"
        if sqlite3_bind_text(statement, 1, (likeQuery as NSString).utf8String, -1, nil) != SQLITE_OK
        {
            print("Error preparing statement")
        }

        var results: [PostalCodeModel] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            let model = PostalCodeModel()
            model.postalCode = String(cString: sqlite3_column_text(statement, 0))
            model.stateH = String(cString: sqlite3_column_text(statement, 1))
            model.cityTownH = String(cString: sqlite3_column_text(statement, 2))
            model.streetH = String(cString: sqlite3_column_text(statement, 3))
            model.stateK = String(cString: sqlite3_column_text(statement, 4))
            model.cityTownK = String(cString: sqlite3_column_text(statement, 5))
            model.streetK = String(cString: sqlite3_column_text(statement, 6))
            results.append(model)
        }

        var uniqueResults: [PostalCodeModel] = []
        for model in results {
            if uniqueResults.isEmpty || uniqueResults.last?.cityTownK != model.cityTownK {
                uniqueResults.append(model)
            }
        }

        return uniqueResults
    }

    func getStreetsByState(_ state: String, byCityAndTown cityTown: String) -> [[PostalCodeModel]] {
        guard openDatabase() != nil else { return [] }
        defer { closeDatabase() }

        let sql = "SELECT * FROM data WHERE state_k LIKE ? AND city_town_k LIKE ?"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(self.database, sql, -1, &statement, nil) == SQLITE_OK else {
            return []
        }
        defer { finalizeStatement(statement) }

        let stateLikeQuery = "%\(state)%"
        let cityTownLikeQuery = "%\(cityTown)%"
        sqlite3_bind_text(statement, 1, (stateLikeQuery as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (cityTownLikeQuery as NSString).utf8String, -1, nil)

        var results: [PostalCodeModel] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            let model = PostalCodeModel()
            model.postalCode = String(cString: sqlite3_column_text(statement, 0))
            model.stateH = String(cString: sqlite3_column_text(statement, 1))
            model.cityTownH = String(cString: sqlite3_column_text(statement, 2))
            model.streetH = String(cString: sqlite3_column_text(statement, 3))
            model.stateK = String(cString: sqlite3_column_text(statement, 4))
            model.cityTownK = String(cString: sqlite3_column_text(statement, 5))
            model.streetK = String(cString: sqlite3_column_text(statement, 6))
            results.append(model)
        }

        var groupedResults: [[PostalCodeModel]] = []
        var currentGroup: [PostalCodeModel] = []

        for model in results {
            if currentGroup.isEmpty {
                currentGroup.append(model)
            } else {
                let currentFirstChar = currentGroup.last?.streetH.first?.description ?? ""
                let newFirstChar = model.streetH.first?.description ?? ""

                if currentFirstChar == newFirstChar {
                    currentGroup.append(model)
                } else {
                    groupedResults.append(currentGroup)
                    currentGroup = [model]
                }
            }
        }

        if !currentGroup.isEmpty {
            groupedResults.append(currentGroup)
        }

        return groupedResults
    }

    // MARK: - Helper Methods

    private func openDatabase() -> OpaquePointer? {
        if sqlite3_open(databasePath, &database) == SQLITE_OK {
            return database
        } else {
            print("Failed to open database.")
            return nil
        }
    }

    private func closeDatabase() {
        if sqlite3_close(database) != SQLITE_OK {
            print("Failed to close database.")
        }
        database = nil
    }

    private func prepareStatement(sql: String) -> OpaquePointer? {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK {
            return statement
        } else {
            print("Failed to prepare statement.")
            return nil
        }
    }

    private func finalizeStatement(_ statement: OpaquePointer?) {
        if sqlite3_finalize(statement) != SQLITE_OK {
            print("Failed to finalize statement.")
        }
    }

    private func divideByState(with array: [PostalCodeModel]) -> [[PostalCodeModel]] {
        var grouped: [[PostalCodeModel]] = []
        var currentGroup: [PostalCodeModel] = []

        for model in array {
            if currentGroup.isEmpty || currentGroup.last?.stateK == model.stateK {
                currentGroup.append(model)
            } else {
                grouped.append(currentGroup)
                currentGroup = [model]
            }
        }

        if !currentGroup.isEmpty {
            grouped.append(currentGroup)
        }

        return grouped
    }
}
