//
//  ChildViewController.swift
//  NCNews
//
//  Created by Sean Molenaar on 16/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage
import TDBadgedCell

class FeedViewController: ListViewController<Feed> {

    override func setupCell(_ cell: TDBadgedCell, item: Feed?) {
        super.setupCell(cell, item: item)
        if let favicon = item?.faviconLink {
            let url = URL(string: favicon)!
            let filter: ImageFilter = AspectScaledToFillSizeFilter(size: CGSize(width: 48, height: 48))
            cell.imageView?.af_setImage(withURL: url, placeholderImage: UIImage(named: "RSS")!, filter: filter)
        }
        if let unread = item?.getUnread(), unread > 0 {
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
        guard let indexPath = tableView.indexPathForSelectedRow, let object = fetchedResultsController.object(at: indexPath) as? Feed else {
            return
        }

        if segue.identifier == "showArticles" {
            let controller: ItemViewController? = (segue.destination as? UINavigationController)?.topViewController as? ItemViewController
            controller?.parentObject = object
            controller?.title = object.title
            configureNew(controller: controller)
        }
    }
}
