//
//  FavoriteRepository.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import Foundation

class FavoriteRepository: NSObject {

    private static let favoriteKey = "favorite"

    static func getFavorites() -> [PostalCodeModel] {
        let defaults = UserDefaults.standard
        guard let favoriteData = defaults.array(forKey: favoriteKey) as? [Data] else {
            return []
        }

        var favorites: [PostalCodeModel] = []
        for data in favoriteData {
            do {
                if let model = try NSKeyedUnarchiver.unarchivedObject(
                    ofClass: PostalCodeModel.self, from: data)
                {
                    favorites.append(model)
                }
            } catch {
                print("Error unarchiving PostalCodeModel: \(error)")
            }
        }
        return favorites
    }

    static func addFavoritePostalCodeModel(_ model: PostalCodeModel) {
        if !isExist(model) {
            var favorites = getFavorites()
            favorites.append(model)
            saveFavorites(favorites)
        }
    }

    static func deleteFavoritePostalCodeModel(at index: Int) {
        var favorites = getFavorites()
        if index < favorites.count {
            favorites.remove(at: index)
            saveFavorites(favorites)
        }
    }

    static func deleteAllFavorite() {
        saveFavorites([])
    }

    static func isExist(_ model: PostalCodeModel) -> Bool {
        let favorites = getFavorites()
        return favorites.contains { $0.postalCode == model.postalCode }
    }

    private static func saveFavorites(_ favorites: [PostalCodeModel]) {
        let defaults = UserDefaults.standard
        var favoriteData: [Data] = []

        for model in favorites {
            do {
                let data = try NSKeyedArchiver.archivedData(
                    withRootObject: model, requiringSecureCoding: true)
                favoriteData.append(data)
            } catch {
                print("Error archiving PostalCodeModel: \(error)")
            }
        }

        defaults.set(favoriteData, forKey: favoriteKey)
        defaults.synchronize()
    }
}
