//
//  DateSortDescriptor.swift
//  NCNews
//
//  Created by Sean Molenaar on 16/10/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import Foundation

class DateSortDescriptor: NSSortDescriptor {
    override func compare(_ object1: Any, to object2: Any) -> ComparisonResult {
        guard let item1 = object1 as? FeedItem,
              let item2 = object2 as? FeedItem,
              let date1 = item1.lastModified as? Date,
              let date2 = item2.lastModified as? Date else {
            return ComparisonResult.orderedSame
        }
        return date1.compare(date2)
    }
}

class NameSortDescriptor: NSSortDescriptor {
    override func compare(_ object1: Any, to object2: Any) -> ComparisonResult {
        if let item1 = object1 as? NCNewsObject, let item2 = object2 as? NCNewsObject {
            return item1.title?.compare(item2.title ?? "") ?? ComparisonResult.orderedSame
        }
        return ComparisonResult.orderedSame
    }
}
