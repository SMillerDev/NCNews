//
//  ImageFinder.swift
//  NCNews
//
//  Created by Sean Molenaar on 19/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
class ImageFinder {
    class func find(_ html: String?, url: URL?) -> URL? {
        guard let html = html, let url = url else {
            return nil
        }
        let tagRegex = "<img.*?/>"
        let urlSpecialRegex = url.scheme! + "://" + url.host! + "/((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let urlRegex = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        guard let tagMatch = html.range(of: tagRegex, options: .regularExpression) else {
            return nil
        }
        let tag = String(html[tagMatch])
        if let urlMatch = tag.range(of: urlSpecialRegex, options: .regularExpression) {
            let urlString = String(tag[urlMatch])
            return URL(string: urlString)
        }
        if let urlMatch = tag.range(of: urlRegex, options: .regularExpression) {
            let urlString = String(tag[urlMatch])
            return URL(string: urlString)
        }
        return nil
    }
}
