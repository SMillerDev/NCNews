//
//  ListViewController.swift
//  NCNews
//
//  Created by Sean Molenaar on 30/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import CoreData
import DATASource
import Sync

class ListViewController<T: NCNewsObject>: UITableViewController, NSFetchedResultsControllerDelegate {

    fileprivate let className: String = {
        let fullName: String = NSStringFromClass(T.self as! AnyClass)
        let range = fullName.range(of: ".")
        if let range = range {
            return String(fullName[range.upperBound...])
        }
        return fullName
    }()

    var parentObject: NCNewsObject?

    let dataStack: DataStack = DataStack()
    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: className)
        if T.dateSorted {
            request.sortDescriptors = [NSSortDescriptor(key: "lastModified", ascending: false)]
        } else {
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }

        if let id = parentObject?.id {
            request.predicate = NSPredicate(format: "parent.id == %d", id)
        }

        let dataSource = DATASource(tableView: self.tableView,
                                    cellIdentifier: className.lowercased() + "Cell",
                                    fetchRequest: request,
                                    mainContext: self.dataStack.mainContext,
                                    configuration: { cell, item, _ in
                                        self.setupCell(cell, item: item as? T)
        })

        return dataSource
    }()

    func setupCell(_ cell: UITableViewCell, item: T?) {
        cell.textLabel?.text = item?.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = NCColor.custom
        navigationController?.navigationBar.tintColor = UIColor.lightText
        self.tableView.dataSource = self.dataSource
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        navigationController?.navigationBar.barTintColor = NCColor.custom
        super.viewWillAppear(animated)
    }

    internal func configureNew(controller: UITableViewController?) {
        controller?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller?.navigationItem.leftItemsSupplementBackButton = true
    }

}
