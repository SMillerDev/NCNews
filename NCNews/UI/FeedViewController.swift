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

class FeedViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    let dataStack: DataStack = DataStack()
    var folder: Folder?
    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Feed")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        if let id = folder?.id {
            request.predicate = NSPredicate(format: "folder.id == %d", id)
        }

        let dataSource = DATASource(tableView: self.tableView,
                                    cellIdentifier: "feedCell",
                                    fetchRequest: request,
                                    mainContext: self.dataStack.mainContext,
                                    configuration: { cell, item, _ in
            if let favicon = item.value(forKey: "faviconLink") as? String {
                let url = URL(string: favicon)!
                cell.imageView?.af_setImage(withURL: url, placeholderImage: UIImage(named: "RSS")!)
            }
            cell.textLabel?.text = item.value(forKey: "title") as? String
        })

        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        self.tableView.dataSource = self.dataSource
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showArticles", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        let object = dataSource.object(indexPath) as! Feed

        if segue.identifier == "showArticles" {
            let controller: ItemViewController? = (segue.destination as? UINavigationController)?.topViewController as? ItemViewController
            controller?.feed = object
            controller?.title = object.title
            configureNew(controller: controller)
        }
    }

    internal func configureNew(controller: UITableViewController?) {
        controller?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller?.navigationItem.leftItemsSupplementBackButton = true
    }
}
