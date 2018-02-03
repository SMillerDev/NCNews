//
//  ChildViewController.swift
//  NCNews
//
//  Created by Sean Molenaar on 16/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import CoreData
import Sync
import DATASource
import AlamofireImage
import TDBadgedCell

class FeedViewController: ListViewController<Feed> {

    override func setupCell(_ cell: UITableViewCell, item: Feed?) {
        super.setupCell(cell, item: item)
        let cell = cell as! TDBadgedCell
        if let favicon = item?.faviconLink {
            let url = URL(string: favicon)!
            cell.imageView?.af_setImage(withURL: url, placeholderImage: UIImage(named: "RSS")!)
        }
        cell.textLabel?.text = item?.title
        if let unread = item?.unreadCount, unread > 0 {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
            cell.badgeString = String(describing: unread)
            cell.badgeColor = NCColor.custom
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showArticles", sender: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        let object = dataSource.object(indexPath) as! Feed

        if segue.identifier == "showArticles" {
            let controller: ItemViewController? = (segue.destination as? UINavigationController)?.topViewController as? ItemViewController
            controller?.parentObject = object
            controller?.title = object.title
            configureNew(controller: controller)
        }
    }
}
