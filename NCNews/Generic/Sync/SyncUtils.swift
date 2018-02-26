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
    
    static func getUnread(_ array: [NCNewsObject]) -> Int {
        if array.isEmpty {
            return 0
        }
        if let first = array.first, first is Feed || first is Folder {
            return 0
        }
        var unread = 0
        array.forEach { object in
            let object = object as! FeedItem
            if object.unread {
                unread += 1
            }
        }
        return unread
    }
}
