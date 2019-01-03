//
//  ListViewController.swift
//  NCNews
//
//  Created by Sean Molenaar on 30/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import CoreData
import TDBadgedCell

class ListViewController<T>: UITableViewController, NSFetchedResultsControllerDelegate, CanReloadView where T: NCNewsObject {
    var dataType: NCNewsObject.Type = T.self

    fileprivate let className: String = {
        return Utils.className(classType: T.self)
    }()

    var parentObject: NCNewsObject?

    lazy internal var appDel: AppDelegate = {
        return (UIApplication.shared.delegate as? AppDelegate)!
    }()
    lazy var context: NSManagedObjectContext = {
        return appDel.persistentContainer!.viewContext
    }()

    internal lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: className)
        request.sortDescriptors = [DateSortDescriptor(), NameSortDescriptor()]

        if let id = parentObject?.id {
            request.predicate = NSPredicate(format: "parent.id == %d", id)
        }

        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                  managedObjectContext: self.context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupCell(_ cell: TDBadgedCell, item: T?) {
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

        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Unable to perform fetch: \(error.localizedDescription)")
        }
    }

    @objc func reloadData(_ pull: Bool = true) {
        print("Starting refresh")
        if pull {
            refreshControl?.beginRefreshing()
            appDel.sync?.refresh().done { _ in
                do {
                    try self.fetchedResultsController.performFetch()
                } catch let error as NSError {
                    print("Unable to perform fetch: \(error.localizedDescription)")
                }
                self.refreshControl?.endRefreshing()
                }.catch { error in
                    print("Reload failed: ", error.localizedDescription)
                    self.refreshControl?.endRefreshing()
            }
            return
        }
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Unable to perform fetch: \(error.localizedDescription)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        navigationController?.navigationBar.barTintColor = NCColor.custom
        do {
            try fetchedResultsController.performFetch()
            view.layoutIfNeeded()
        } catch {
            print("Failed to refresh previous page")
        }
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
        if sectionCount == 0 || fetchedResultsController.sections?[0].numberOfObjects == 0 { TableViewHelper.emptyMessage(self, type: T.self) }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: className.lowercased() + "Cell", for: indexPath)
        guard let castCell = cell as? TDBadgedCell else {
            return cell
        }
        let item = fetchedResultsController.object(at: indexPath) as? T
        setupCell(castCell, item: item)
        return cell
    }

    // MARK: - FetchedResultsController Delegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default: break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        guard let cell = self.tableView.cellForRow(at: newIndexPath!) as? TDBadgedCell else {
            return
        }
        // 2
        switch type {
        case .update:
            let item = fetchedResultsController.object(at: indexPath!) as? T
            DispatchQueue.main.async {
                self.setupCell(cell, item: item)
            }
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default: break
        }
    }
}
