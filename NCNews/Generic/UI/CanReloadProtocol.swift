//
//  CanReloadProtocol.swift
//  NCNews
//
//  Created by Sean Molenaar on 06/03/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import Foundation
protocol CanReloadView {
    var dataType: NCNewsObject.Type { get }
    func reloadData(_ pull: Bool)
}
