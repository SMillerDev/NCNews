//
//  BasicAuthAdapter.swift
//  NCNews
//
//  Created by Sean Molenaar on 13/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import Alamofire

class BasicAuthAdapter: NextCloudAPIAdapter {

    private let auth: String

    init(user: String, password: String) {
        let plainString = "\(user):\(password)" as String
        let plainData = plainString.data(using: .utf8)
        auth = plainData!.base64EncodedString(options: .init(rawValue: 0))
    }

    override func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = try super.adapt(urlRequest)

        urlRequest.setValue("Basic "+auth, forHTTPHeaderField: "Authorization")

        return urlRequest
    }
}
