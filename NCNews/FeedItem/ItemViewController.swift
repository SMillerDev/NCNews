//
//  ItemViewController.swift
//  NCNews
//
//  Created by Sean Molenaar on 16/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import CoreData
import TDBadgedCell
import AlamofireImage

class ItemViewController: ListViewController<FeedItem> {

    var detailViewController: DetailViewController?
    weak var delegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate

    override func setupCell(_ cell: TDBadgedCell, item: FeedItem?) {
        super.setupCell(cell, item: item)
        cell.detailTextLabel?.text = item?.lead
        if let url = item?.image {
            let filter: ImageFilter = AspectScaledToFillSizeFilter(size: CGSize(width: 48, height: 48))
            cell.imageView?.af_setImage(withURL: URL(string: url)!, placeholderImage: UIImage(named: "News")!, filter: filter)
        }

        if let unread = item?.unread, unread {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!)
        }

        if let starred = item?.starred, starred {
            cell.badgeString = "⭐️"
        } else {
            cell.badgeString = ""
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
        if segue.identifier == "showDetail", let indexPath = tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.object(at: indexPath)
            delegate?.sync?.markRead(object as? FeedItem)
            let controller = (segue.destination as? UINavigationController)?.topViewController as? DetailViewController
            controller?.detailItem = object as? FeedItem
            controller?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller?.navigationItem.leftItemsSupplementBackButton = true
        }
    }

}
