//
//  LeadFinder.swift
//  NCNews
//
//  Created by Sean Molenaar on 22/02/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit

class LeadFinder: Any {
    class func find(_ html: String?) -> String? {
        guard let html = html else {
            return nil
        }
        let myRegex = "<.*?>"
        let fix = html.replacingOccurrences(of: myRegex, with: "", options: .regularExpression, range: nil)
        if fix.endIndex.encodedOffset <= 200 {
            return fix
        }
        return fix[fix.startIndex.encodedOffset...200]
    }
}
