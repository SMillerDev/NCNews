//
//  ListViewController.swift
//  NCNews
//
//  Created by Sean Molenaar on 30/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import CoreData
import Sync

class ListViewController<T: NCNewsObject>: UITableViewController, NSFetchedResultsControllerDelegate {

    fileprivate let className: String = {
        return Utils.className(classType: T.self)
    }()

    var parentObject: NCNewsObject?
    lazy var context: NSManagedObjectContext = {
        let appDel: AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        return appDel.persistentContainer!.viewContext
    }()

    internal lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: className)
        if T.dateSorted {
            request.sortDescriptors = [NSSortDescriptor(key: "lastModified", ascending: false)]
        } else {
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }

        if let id = parentObject?.id {
            request.predicate = NSPredicate(format: "parent.id == %d", id)
        }

        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    func setupCell(_ cell: UITableViewCell, item: T?) {
        cell.textLabel?.text = item?.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = NCColor.custom
        navigationController?.navigationBar.tintColor = UIColor.lightText

        tableView.dataSource = self
        tableView.delegate = self

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.reloadData), for: UIControlEvents.valueChanged)

        reloadData()
    }

    @objc func reloadData() {
        refreshControl?.beginRefreshing()
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Unable to perform fetch: \(error.localizedDescription)")
        }
        refreshControl?.endRefreshing()
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

    // MARK: UITableViewDataSource
    //Number of section
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sectionCount = fetchedResultsController.sections?.count else {
            return 0
        }
        if sectionCount == 0 { TableViewHelper.emptyMessage(self, message: "Sorry, no \(className)s here") }
        return sectionCount
    }

    //Number of section in row
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionData = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionData.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: className.lowercased() + "Cell", for: indexPath as IndexPath)
        configureCell(cell: cell, forRowAtIndexPath: indexPath)
        return cell
    }

    func configureCell(cell: UITableViewCell, forRowAtIndexPath: IndexPath) {
        let item = fetchedResultsController.object(at: forRowAtIndexPath) as? T
        setupCell(cell, item: item)
    }

    // MARK: - FetchedResultsController Delegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
