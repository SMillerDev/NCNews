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

class ItemViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController?
    var feed: NSManagedObject?
    let dataStack: DataStack = DataStack()
    var folder: Folder?

    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FeedItem")
        request.sortDescriptors = [NSSortDescriptor(key: "pubDate", ascending: false)]
        if let id = (feed as? Feed)?.id {
            request.predicate = NSPredicate(format: "feed.id == %d", id)
        }

        let dataSource = DATASource(tableView: self.tableView,
                                    cellIdentifier: "itemCell",
                                    fetchRequest: request,
                                    mainContext: self.dataStack.mainContext,
                                    configuration: { cell, item, _ in
            cell.textLabel?.text = item.value(forKey: "title") as? String
            cell.detailTextLabel?.text = item.value(forKey: "lead") as? String
            if let url = item.value(forKey: "image") as? String {
                cell.imageView?.af_setImage(withURL: URL(string: url)!, placeholderImage: UIImage(named: "News")!)
            }
        })

        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.tableView.dataSource = self.dataSource

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as? UINavigationController)?.topViewController as? DetailViewController
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = self.dataSource.object(indexPath)
                let controller = (segue.destination as? UINavigationController)?.topViewController as? DetailViewController
                controller?.detailItem = object as? FeedItem
                controller?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller?.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

}
