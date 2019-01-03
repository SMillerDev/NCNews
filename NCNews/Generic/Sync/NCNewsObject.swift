//
// Created by Sean Molenaar on 27/01/2018.
// Copyright (c) 2018 Sean Molenaar. All rights reserved.
//

import Foundation
import CoreData

protocol NCNewsObject {
    /// The ID of the object
    var id: Int64 { get set }

    /// The title of the object
    var title: String? { get set }

    /// The parent entity name
    static var parentName: String? { get }

    /// Initialize the object with JSON
    /// This will fill all values
    func fill(with json: [String: Any])
}
