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
        guard let hash = "\(user):\(password)".data(using: .isoLatin1)?.base64EncodedString() else {
            fatalError("Failed to generate hash")
        }
        auth = hash
    }

    override func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = try super.adapt(urlRequest)

        urlRequest.setValue("Basic "+auth, forHTTPHeaderField: "Authorization")

        return urlRequest
    }
}
