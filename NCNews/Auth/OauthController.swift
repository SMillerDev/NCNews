//
//  OauthController.swift
//  NCNews
//
//  Created by Sean Molenaar on 13/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import OAuthSwift
import Foundation

extension LoginViewController {
    func oauthLogin(_ url: URL) {
        let oauthswift = OAuth2Swift(
            consumerKey: secretField.text!,
            consumerSecret: "",
            authorizeUrl: url.absoluteString+"/index.php/apps/oauth2/authorize",
            accessTokenUrl: url.absoluteString+"/index.php/apps/oauth2/api/v1/token",
            responseType: "code"
        )
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
        oauthswift.authorize(
            withCallbackURL: URL(string: "eu.seanmolenaar.NCNews://oauth-callback/nextcloud")!,
            scope: "profile",
            state: "NEXTCLOUD",
            success: { credential, _, _ in
                self.delegate?.sync = Sync(url, container: (self.delegate?.persistentContainer)!, token: credential.oauthToken)
                UserDefaults.standard.set(true, forKey: DefaultConstants.didLogin)
                self.delegate?.sync?.refresh().done {
                    print("Fetched new items")
                }.catch { error in
                        print(error.localizedDescription)
                }
                self.performSegue(withIdentifier: "logginSegue", sender: nil)
        },
            failure: { error in
                print(error.localizedDescription)
                self.errorText.text = error.localizedDescription
        }
        )
    }
}
