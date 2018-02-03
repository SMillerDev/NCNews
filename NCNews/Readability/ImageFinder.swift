//
//  ImageFinder.swift
//  NCNews
//
//  Created by Sean Molenaar on 19/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
class ImageFinder {
    class func find(html: String, url: URL) -> URL? {
        let html = "<html><body\(html)</body></html>"

        return URL(string: "https://raw.githubusercontent.com/nextcloud/news/master/screenshots/1.png")
    }
}
