//
//  NextCloudAPIAdapter.swift
//  NCNews
//
//  Created by Sean Molenaar on 13/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import Alamofire

class NextCloudAPIAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue("true", forHTTPHeaderField: "OCS-APIRequest")
        return urlRequest
    }
}
