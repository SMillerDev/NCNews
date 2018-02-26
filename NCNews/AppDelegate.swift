//
//  AppDelegate.swift
//  NCNews
//
//  Created by Sean Molenaar on 10/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import CoreData
import OAuthSwift
import AlamofireNetworkActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?
    var sync: Sync?
    var persistentContainer: NSPersistentContainer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        debugPrint(paths[0])
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        NetworkActivityIndicatorManager.shared.isEnabled = true
        setupCoreData()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.absoluteString.starts(with: "eu.seanmolenaar.ncnews://oauth-callback/") {
            OAuthSwift.handle(url: url)
        } else if url.absoluteString.starts(with: "eu.seanmolenaar.ncnews://oauth/") {
            print(url.lastPathComponent)
            UserDefaults.standard.set(url.lastPathComponent, forKey: DefaultConstants.authKey)
        }
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let splitview = window?.rootViewController as? UISplitViewController else {
            completionHandler(.failed)
            return
        }
        let viewControllers = splitview.viewControllers
        for viewController in viewControllers {
            if let listviewController = viewController as? ListViewController<FeedItem> {
                sync!.fetch(FeedItem.self).done {_ -> Void in
                    listviewController.reloadData()
                    return completionHandler(.newData)
                }.catch { _ in
                    completionHandler(.failed)
                }
            } else if let listviewController = viewController as? ListViewController<Feed> {
                sync!.fetch(Feed.self).done {_ -> Void in
                    listviewController.reloadData()
                    return completionHandler(.newData)
                }.catch { _ in
                    completionHandler(.failed)
                }
            } else if let listviewController = viewController as? ListViewController<Folder> {
                sync!.fetch(Folder.self).done {_ -> Void in
                    listviewController.reloadData()
                    return completionHandler(.newData)
                }.catch { _ in
                    completionHandler(.failed)
                }
            } else if let detailView: DetailViewController = viewController as? DetailViewController {
                sync!.fetch(FeedItem.self).done {_ in
                    detailView.configureView()
                    return completionHandler(.newData)
                }.catch { _ in
                    completionHandler(.failed)
                }
            }
        }
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

    // MARK: - Core Data Saving support

    func setupCoreData() {
        let persistentContainer = NSPersistentContainer(name: "NCNews")
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        self.persistentContainer = persistentContainer
        debugPrint(self.persistentContainer!.persistentStoreDescriptions.first.debugDescription)
    }

    func saveContext () {
        if let changes = persistentContainer?.viewContext.hasChanges, changes {
            do {
                try persistentContainer?.viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
