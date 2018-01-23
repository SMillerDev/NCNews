//
//  MasterViewController.swift
//  NCNews
//
//  Created by Sean Molenaar on 10/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import CoreData
import DATASource
import Sync

class FolderViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    let dataStack: DataStack = DataStack()
    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Folder")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let dataSource = DATASource(tableView: self.tableView,
                                    cellIdentifier: "folderCell",
                                    fetchRequest: request,
                                    mainContext: self.dataStack.mainContext,
                                    configuration: { cell, item, _ in
            cell.textLabel?.text = item.value(forKey: "name") as? String
        })

        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = NCColor.custom
        navigationController?.navigationBar.tintColor = UIColor.lightText
        self.tableView.dataSource = self.dataSource
        splitViewController?.viewControllers[1].dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showFeeds", sender: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        navigationController?.navigationBar.barTintColor = NCColor.custom
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func showSettings(sender: Any?) {
        self.performSegue(withIdentifier: "showSettings", sender: nil)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        let object = dataSource.object(indexPath) as! Folder

        if segue.identifier == "showFeeds" {
            let controller: FeedViewController? = (segue.destination as? UINavigationController)?.topViewController as? FeedViewController
            controller?.folder = object
            controller?.title = object.name
            configureNew(controller: controller)
        } else if segue.identifier == "showArticles" {
            let controller: ItemViewController? = (segue.destination as? UINavigationController)?.topViewController as? ItemViewController
            controller?.feed = object
            controller?.title = object.name
            configureNew(controller: controller)
        }
    }

    internal func configureNew(controller: UITableViewController?) {
        controller?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller?.navigationItem.leftItemsSupplementBackButton = true
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = dataStack.mainContext
            context.delete(dataSource.object(indexPath)!)

            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
