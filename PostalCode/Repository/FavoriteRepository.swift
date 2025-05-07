//
//  FavoriteRepository.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import Foundation

class FavoriteRepository {

    private static let favoriteKey = "favorite"

    static func getFavorites() -> [PostalCode] {
        let defaults = UserDefaults.standard
        guard let favoriteData = defaults.array(forKey: favoriteKey) as? [Data] else {
            return []
        }

        var favorites: [PostalCode] = []
        for data in favoriteData {
            do {
                if let postalCode = try NSKeyedUnarchiver.unarchivedObject(
                    ofClass: PostalCode.self, from: data)
                {
                    favorites.append(postalCode)
                }
            } catch {
                print("Error unarchiving PostalCode: \(error)")
            }
        }
        return favorites
    }

    static func addFavorite(_ postalCode: PostalCode) {
        if !isExist(postalCode) {
            var favorites = getFavorites()
            favorites.append(postalCode)
            saveFavorites(favorites)
        }
    }

    static func deleteFavorite(at index: Int) {
        var favorites = getFavorites()
        if index < favorites.count {
            favorites.remove(at: index)
            saveFavorites(favorites)
        }
    }

    static func deleteAllFavorite() {
        saveFavorites([])
    }

    static func isExist(_ postalCode: PostalCode) -> Bool {
        let favorites = getFavorites()
        return favorites.contains { $0.code == postalCode.code }
    }

    private static func saveFavorites(_ favorites: [PostalCode]) {
        let defaults = UserDefaults.standard
        var favoriteData: [Data] = []

        for postalCode in favorites {
            do {
                let data = try NSKeyedArchiver.archivedData(
                    withRootObject: postalCode, requiringSecureCoding: true)
                favoriteData.append(data)
            } catch {
                print("Error archiving PostalCode: \(error)")
            }
        }

        defaults.set(favoriteData, forKey: favoriteKey)
        defaults.synchronize()
    }
}
