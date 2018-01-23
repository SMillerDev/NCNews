//
//  NetworkManager.swift
//  NCNews
//
//  Created by Sean Molenaar on 11/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import Alamofire
import Sync

class NetworkManager {
    let baseUrl: URL

    let datastack: DataStack = DataStack()

    let sessionManager: SessionManager = {
        var conf = URLSessionConfiguration.ephemeral
        conf.requestCachePolicy = .useProtocolCachePolicy
        conf.timeoutIntervalForRequest = 200
        return SessionManager(configuration: conf, delegate: SessionDelegate(), serverTrustPolicyManager: nil)
    }()

    static let newsApiPath: String = "/index.php/apps/news/api/v1-2"

    init(_ url: URL, token: String) {
        baseUrl = url.appendingPathComponent(NetworkManager.newsApiPath)
        sessionManager.adapter = AccessTokenAdapter(accessToken: token)
        setup()
    }

    init(_ url: URL, user: String, pass: String) {
        baseUrl = url.appendingPathComponent(NetworkManager.newsApiPath)
        sessionManager.adapter = BasicAuthAdapter(user: user, password: pass)
        setup()
    }

    func setup() {
        // SETUP
    }

    func initial_sync() {
        if UserDefaults.standard.bool(forKey: "initialSync") {
            items(read: true, starred: false)
            folders({
                self.feeds()
            })
            return
        }
        folders({
            self.feeds({
                self.items({
                    UserDefaults.standard.set(true, forKey: "initialSync")
                })
            })
        })
    }

    func folders(_ completionHandler: @escaping () -> Void? = {return}) {
        sessionManager.request(baseUrl.appendingPathComponent("/folders")).responseJSON { response in
            if let json: [String: Any] = response.result.value as? [String: Any] {
                self.saveToDB(array: json["folders"] as? [[String: Any]], name: "Folder")
                completionHandler()
            }
        }
    }

    func feeds(_ completionHandler: @escaping () -> Void? = {return}) {
        sessionManager.request(baseUrl.appendingPathComponent("/feeds")).responseJSON { response in
            if let json: [String: Any] = response.result.value as? [String: Any] {
                var newFeeds: [[String: Any]] = []
                let feeds = json["feeds"] as? [[String: Any]]
                feeds?.forEach({ item in
                    var item = item
                    item["folder_id"] = item["folderId"]
                    newFeeds.append(item)
                })
                self.saveToDB(array: newFeeds, name: "Feed")
                completionHandler()
            }
        }
    }

    func items(_ completionHandler: @escaping () -> Void? = {return}, read: Bool = true, starred: Bool = false) {
        var param: Parameters = ["getRead": read, "type": 3]
        if starred {
            param["type"] = 2
        }
        sessionManager.request(baseUrl.appendingPathComponent("/items"), parameters: param).responseJSON { response in
            if let json: [String: Any] = response.result.value as? [String: Any] {
                var newItems: [[String: Any]] = []
                let items = json["items"] as? [[String: Any]]
                items?.forEach({ item in
                    var item = item
                    item["feed_id"] = item["feedId"]
                    if let body = item["body"] as? String {
                        if let img = ImageFinder.find(html: body) {
                            item["image"] = img.absoluteString
                        } else {
                            debugPrint("No info could be extracted")
                        }
                    }
                    newItems.append(item)
                })
                self.saveToDB(array: newItems, name: "FeedItem")
                completionHandler()
            }
        }
    }

    internal func saveToDB(array: [[String: Any]]?, name: String) {
        if array == nil {
            debugPrint("No value to store")
            return
        }
        self.datastack.sync(array!, inEntityNamed: name, completion: { error in
            guard error == nil else {
                debugPrint("Failed to sync folders: " + error!.localizedDescription)
                return
            }
        })
    }
}
