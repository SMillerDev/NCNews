//
//  NetworkConvenience.swift
//  NCNews
//
//  Created by Sean Molenaar on 13/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

extension NetworkManager {
    static func getColor(url: String, completionHandler: @escaping (UIColor) -> Void) {
        let url = URL(string: url)!
        var color: UIColor = NCColor.ncDefault
        Alamofire.request(url.appendingPathComponent("/login")).responseString(completionHandler: { response in
            guard let responseString = response.value else {
                completionHandler(color)
                return
            }
            guard let match = responseString.range(of: "<meta name=\"theme-color\" content=\"#([A-F0-9]{3,6})\">",
                                                    options: .regularExpression) else {
                completionHandler(color)
                return
            }
            guard let colorMatch = responseString[match].range(of: "#([A-F0-9]{3,6})", options: .regularExpression) else {
                completionHandler(color)
                return
            }
            color = UIColor(hexString: String(responseString[match][colorMatch]), alpha: 0)
            NCColor.set(String(responseString[match][colorMatch]))
            completionHandler(color)
        })
        completionHandler(color)
    }
}
