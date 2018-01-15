//
//  AccessTokenAdapter.swift
//  NCNews
//
//  Created by Sean Molenaar on 13/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import Alamofire

class AccessTokenAdapter: NextCloudAPIAdapter {
    private let accessToken: String

    init(accessToken: String) {
        self.accessToken = accessToken
    }

    override func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = try super.adapt(urlRequest)
        urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")

        return urlRequest
    }
}
