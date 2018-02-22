//
//  Utils.swift
//  NCNews
//
//  Created by Sean Molenaar on 05/02/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import Foundation

class Utils {
    static func className<T>(classType: T) -> String {
        let fullName: String = NSStringFromClass(classType as! AnyClass)
        let range = fullName.range(of: ".")
        if let range = range {
            return String(fullName[range.upperBound...])
        }
        return fullName
    }

    static func jsonCast<T>(_ classType: T, json: [String: Any], item: String) -> T? {
        return json[item] as? T
    }

    static func jsonForceCast<T>(_ classType: T, json: [String: Any], item: String) -> T {
        return Utils.jsonCast(T.self, json: json, item: item) as! T
    }
}
