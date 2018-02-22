//
//  NetworkManager.swift
//  NCNews
//
//  Created by Sean Molenaar on 11/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import PromiseKit

class NetworkManager {
    let baseUrl: URL
    let container: NSPersistentContainer

    let sessionManager: SessionManager = {
        var conf = URLSessionConfiguration.ephemeral
        conf.requestCachePolicy = .useProtocolCachePolicy
        conf.timeoutIntervalForRequest = 200
        return SessionManager(configuration: conf, delegate: SessionDelegate(), serverTrustPolicyManager: nil)
    }()

    static let newsApiPath: String = "/index.php/apps/news/api/v1-2"

    init(_ url: URL, container: NSPersistentContainer, token: String) {
        baseUrl = url.appendingPathComponent(NetworkManager.newsApiPath)
        sessionManager.adapter = AccessTokenAdapter(accessToken: token)
        self.container = container
        setup()
    }

    init(_ url: URL, container: NSPersistentContainer, user: String, pass: String) {
        baseUrl = url.appendingPathComponent(NetworkManager.newsApiPath)
        sessionManager.adapter = BasicAuthAdapter(user: user, password: pass)
        self.container = container
        setup()
    }

    func setup() {
        // SETUP
    }

    func folders() -> Promise<[[String: Any]]?> {
        return sessionManager.request(baseUrl.appendingPathComponent("/folders")).responseJSON().then { (response) -> Promise<[[String: Any]]?> in
            if let json: [String: Any] = response.json as? [String: Any] {
                let folders = json["folders"] as? [[String: Any]]
                return .value(folders)
            }
            return Promise<[[String: Any]]?>(error: ImportError())
        }
    }

    func feeds() -> Promise<[[String: Any]]?> {
        return sessionManager.request(baseUrl.appendingPathComponent("/feeds")).responseJSON().then { (response) -> Promise<[[String: Any]]?> in
            if let json: [String: Any] = response.json as? [String: Any] {
                let feeds = json["feeds"] as? [[String: Any]]
                return .value(feeds)
            }
            return Promise<[[String: Any]]?>(error: ImportError())
        }
    }

    func items(read: Bool = true, starred: Bool = false) -> Promise<[[String: Any]]?> {
        var param: Parameters = ["getRead": read, "type": 3]
        if starred {
            param["type"] = 2
        }
        return sessionManager.request(baseUrl.appendingPathComponent("/items"), parameters: param)
                             .responseJSON()
                             .then { (response) -> Promise<[[String: Any]]?> in
            if let json: [String: Any] = response.json as? [String: Any] {
                let items = json["items"] as? [[String: Any]]
                return .value(items)
            }
            return Promise<[[String: Any]]?>(error: ImportError())
        }
    }

    func markRead(_ object: NCNewsObject?, read: Bool = true) -> Promise<(string: String, response: PMKAlamofireDataResponse)> {
        var ids: [Int64] = []
        if let item = object as? Folder {
            ids.append(contentsOf: item.childIDs())
        }
        if let item = object as? Feed {
            _ = item.children?.sorted(by: { old, new in old.pubDate?.compare(new.pubDate! as Date) == ComparisonResult.orderedDescending }).first
            ids.append(contentsOf: item.childIDs())
        }
        if let item = object as? FeedItem {
            ids = [item.id]
        }
        let url = read ? "/items/read/multiple" : "/items/unread/multiple"
        return sessionManager.request(baseUrl.appendingPathComponent(url), method: .put, parameters: ["items": ids]).responseString()
    }

    func markStarred(_ object: NCNewsObject?, starred: Bool = true) -> Promise<(string: String, response: PMKAlamofireDataResponse)> {
        guard let item = object as? FeedItem else {
            return Promise<(string: String, response: PMKAlamofireDataResponse)>(error: ImportError())
        }
        if item.starred == starred {
            return Promise<(string: String, response: PMKAlamofireDataResponse)>(error: UploadError())
        }
        let url = starred ? "/items/star/multiple" : "/items/unstar/multiple"
        let params = ["items": [["feedId": String(item.parent.id), "guidHash": item.guidHash]]]
        return sessionManager.request(baseUrl.appendingPathComponent(url), method: .put, parameters: params).responseString()
    }
}

class ImportError: Error {
    let message = "Failed to import items"
}
class UploadError: Error {
    let message = "Failed to upload items"
}
