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
    }

    init(_ url: URL, user: String, pass: String) {
        baseUrl = url.appendingPathComponent(NetworkManager.newsApiPath)
        sessionManager.adapter = BasicAuthAdapter(user: user, password: pass)
    }

    func sync() {
        feeds()
        folders()
        items()
    }

    func folders() {
        sessionManager.request(baseUrl.appendingPathComponent("/folders")).responseJSON { response in
            if let json: [String: Any] = response.result.value as? [String: Any] {
                self.saveToDB(array: json["folders"] as! [[String: Any]], name: "Folder")
            }

        }
    }

    func feeds() {
        sessionManager.request(baseUrl.appendingPathComponent("/feeds")).responseJSON { response in
            if let json: [String: Any] = response.result.value as? [String: Any] {
                self.saveToDB(array: json["feeds"] as! [[String: Any]], name: "Feed")
            }
        }
    }

    func items() {
        sessionManager.request(baseUrl.appendingPathComponent("/items")).responseJSON { response in
            if let json: [String: Any] = response.result.value as? [String: Any] {
                self.saveToDB(array: json["items"] as! [[String: Any]], name: "FeedItem")
            }
        }
    }

    internal func saveToDB(array: [[String: Any]], name: String) {
        print(array)
        self.datastack.sync(array, inEntityNamed: name, completion: { error in
            guard error == nil else {
                debugPrint("Failed to sync folders: " + error!.localizedDescription)
                return
            }
        })
    }
}
