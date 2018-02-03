//
// Created by Sean Molenaar on 27/01/2018.
// Copyright (c) 2018 Sean Molenaar. All rights reserved.
//

import Foundation
import CoreData

protocol NCNewsObject {
    var id: Int64 { get set }
    var title: String? { get set }
    static var dateSorted: Bool { get }
    func fill(with json: [String: AnyObject])
}
