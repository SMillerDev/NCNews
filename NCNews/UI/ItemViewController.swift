//
//  ItemViewController.swift
//  NCNews
//
//  Created by Sean Molenaar on 16/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import CoreData
import Sync
import DATASource

class ItemViewController: ListViewController<FeedItem> {

    var detailViewController: DetailViewController?
    weak var delegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate

    override func setupCell(_ cell: UITableViewCell, item: FeedItem?) {
        super.setupCell(cell, item: item)
        cell.detailTextLabel?.text = item?.lead
        if let url = item?.image {
            cell.imageView?.af_setImage(withURL: URL(string: url)!, placeholderImage: UIImage(named: "News")!)
        }
        if let unread = item?.unread, unread {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.searchController = UISearchController(searchResultsController: self)
//        self.searchController.delegate = self
//        self.searchController.searchResultsUpdater = self
//        self.searchController.searchBar.scopeButtonTitles = ["Unread", "Starred", "All"]
//        self.searchController.searchBar.tintColor = UIColor.lightText
//        self.clearsSelectionOnViewWillAppear = false
//        self.tableView.dataSource = self.dataSource
//        if #available(iOS 11.0, *) {
//            self.navigationItem.searchController = searchController
//        } else {
//            self.tableView.tableHeaderView = self.searchController.searchBar
//        }

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as? UINavigationController)?.topViewController as? DetailViewController
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: nil)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = self.dataSource.object(indexPath)
                delegate?.sync?.markRead(object as? FeedItem)
                let controller = (segue.destination as? UINavigationController)?.topViewController as? DetailViewController
                controller?.detailItem = object as? FeedItem
                controller?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller?.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

}
