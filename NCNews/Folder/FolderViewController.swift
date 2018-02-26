//
//  MasterViewController.swift
//  NCNews
//
//  Created by Sean Molenaar on 10/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import CoreData
import TDBadgedCell

class FolderViewController: ListViewController<Folder> {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showFeeds", sender: nil)
    }
    
    override func setupCell(_ cell: TDBadgedCell, item: Folder?) {
        super.setupCell(cell, item: item)
        if let unread = item?.getUnread(), unread > 0 {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
            cell.badgeString = String(describing: unread)
            cell.badgeColor = NCColor.custom
        }
    }

    @objc
    func showSettings(sender: Any?) {
        self.performSegue(withIdentifier: "showSettings", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        splitViewController?.viewControllers.first?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow, let object = fetchedResultsController.object(at: indexPath) as? Folder else {
            return
        }

        if segue.identifier == "showFeeds" {
            let controller: FeedViewController? = (segue.destination as? UINavigationController)?.topViewController as? FeedViewController
            controller?.parentObject = object
            controller?.title = object.title
            configureNew(controller: controller)
        } else if segue.identifier == "showArticles" {
            let controller: ItemViewController? = (segue.destination as? UINavigationController)?.topViewController as? ItemViewController
            controller?.parentObject = object
            controller?.title = object.title
            configureNew(controller: controller)
        }
    }
}
