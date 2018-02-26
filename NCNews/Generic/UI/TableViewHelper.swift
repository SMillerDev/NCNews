//
//  TableViewHelper.swift
//  NCNews
//
//  Created by Sean Molenaar on 13/02/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import Foundation
import UIKit

class TableViewHelper {

    class func emptyMessage<T: NCNewsObject>(_ viewController: UITableViewController, type: T.Type) {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0),
                          size: CGSize(width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        switch Utils.className(classType: type) {
        case Utils.className(classType: FeedItem.self):
            messageLabel.text = "We couldn't load any items from your feed for you."
        case Utils.className(classType: Feed.self):
            messageLabel.text = "This folder seems to be empty."
        case Utils.className(classType: Folder.self):
            messageLabel.text = "No Folders of Feeds could be found, add some in the web interface."
        default:
            messageLabel.text = "We couldn't load any items for you."
        }
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        viewController.tableView.backgroundView = messageLabel
        viewController.tableView.separatorStyle = .none
    }
}
