//
//  BasicAuthController.swift
//  NCNews
//
//  Created by Sean Molenaar on 13/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit

extension LoginViewController {
    func basicAuth(_ url: URL, user: String? = nil) {
        if let userName = user {
            do {
                let passwordItem = self.keychain(account: userName)
                let keychainPassword = try passwordItem.readPassword()
                self.auth(url, user: userName, password: keychainPassword)
            } catch {
                fatalError("Error reading password from keychain - \(error)")
            }
            return
        }
        guard let newAccountName = userField.text,
            let newPassword = passwordField.text,
            !newAccountName.isEmpty && !newPassword.isEmpty && segmentControl.selectedSegmentIndex == 0 else {
            reportError(error: "Wrong username or password.", alert: true)
            return
        }

        userField.resignFirstResponder()
        passwordField.resignFirstResponder()

        let hasLoginKey = UserDefaults.standard.bool(forKey: DefaultConstants.didLogin)
        if !hasLoginKey {
            UserDefaults.standard.setValue(userField.text, forKey: DefaultConstants.username)
        }

        do {
            let passwordItem = self.keychain(account: newAccountName)
            try passwordItem.savePassword(newPassword)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
        self.auth(url, user: newAccountName, password: newPassword)
    }

    internal func auth(_ url: URL, user: String, password: String) {
        UserDefaults.standard.set(true, forKey: DefaultConstants.didLogin)
        self.delegate?.networkManager = NetworkManager(url, user: user, pass: password)
        self.delegate?.networkManager?.initial_sync()
        self.performSegue(withIdentifier: "logginSegue", sender: nil)
    }

    internal func keychain(account: String) -> KeychainPasswordItem {
        return KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                    account: account,
                                accessGroup: KeychainConfiguration.accessGroup)
    }
}
