//
//  PostalCodeModel.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import Foundation

@objcMembers
class PostalCodeModel: NSObject, NSSecureCoding, @unchecked Sendable {
    var postalCode: String = ""  // 郵便番号
    var stateH: String = ""  // 都道府県（平仮名）
    var cityTownH: String = ""  // 市町村（平仮名）
    var streetH: String = ""  // 区群（平仮名）
    var stateK: String = ""  // 都道府県（漢字）
    var cityTownK: String = ""  // 市町村（漢字）
    var streetK: String = ""  // 区群（漢字）

    // MARK: - NSSecureCoding

    static var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder: NSCoder) {
        postalCode = coder.decodeObject(of: NSString.self, forKey: "postalCode") as String? ?? ""
        stateH = coder.decodeObject(of: NSString.self, forKey: "stateH") as String? ?? ""
        cityTownH = coder.decodeObject(of: NSString.self, forKey: "cityTownH") as String? ?? ""
        streetH = coder.decodeObject(of: NSString.self, forKey: "streetH") as String? ?? ""
        stateK = coder.decodeObject(of: NSString.self, forKey: "stateK") as String? ?? ""
        cityTownK = coder.decodeObject(of: NSString.self, forKey: "cityTownK") as String? ?? ""
        streetK = coder.decodeObject(of: NSString.self, forKey: "streetK") as String? ?? ""
    }

    func encode(with coder: NSCoder) {
        coder.encode(postalCode, forKey: "postalCode")
        coder.encode(stateH, forKey: "stateH")
        coder.encode(cityTownH, forKey: "cityTownH")
        coder.encode(streetH, forKey: "streetH")
        coder.encode(stateK, forKey: "stateK")
        coder.encode(cityTownK, forKey: "cityTownK")
        coder.encode(streetK, forKey: "streetK")
    }

    override init() {
        super.init()
    }
}
