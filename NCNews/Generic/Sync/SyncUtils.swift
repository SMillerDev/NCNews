//
//  Utils.swift
//  NCNews
//
//  Created by Sean Molenaar on 05/02/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import Foundation
import CoreSpotlight
import MobileCoreServices

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
            if let object = object as? FeedItem, object.unread {
                unread += 1
            }
        }
        return unread
    }
}

extension Sync {
    internal func spotlightIndex(_ items: [NCNewsObject]) {
        guard let items = items as? [FeedItem] else {
            return
        }
        var splItems: [CSSearchableItem] = []
        items.forEach { item in
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            attributeSet.title = item.title
            if let url = item.url { attributeSet.url = URL(string: url)}
            if let author = item.author { attributeSet.publishers = [author]}
            attributeSet.contentDescription = item.lead
            attributeSet.contentCreationDate = item.pubDate as Date?
            let splItem = CSSearchableItem(uniqueIdentifier: "\(item.objectID)",
                domainIdentifier: "eu.seanmolenaar.NCNews",
                attributeSet: attributeSet)
            splItems.append(splItem)
        }

        CSSearchableIndex.default().indexSearchableItems(splItems) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
}
