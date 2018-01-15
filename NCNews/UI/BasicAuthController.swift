//
//  BasicAuthController.swift
//  NCNews
//
//  Created by Sean Molenaar on 13/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit

extension LoginViewController {
    func basicAuth(_ url: URL) {
        guard let newAccountName = userField.text,
            let newPassword = passwordField.text,
            !newAccountName.isEmpty && !newPassword.isEmpty && segmentControl.selectedSegmentIndex == 0 else {
            reportError(error: "Wrong username or password.", alert: true)
            return
        }

        userField.resignFirstResponder()
        passwordField.resignFirstResponder()

        let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if !hasLoginKey {
            UserDefaults.standard.setValue(userField.text, forKey: "NCusername")
        }

        do {
            // This is a new account, create a new keychain item with the account name.
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: newAccountName,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            // Save the password for the new item.
            try passwordItem.savePassword(newPassword)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }

        // 6
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
        self.delegate?.networkManager = NetworkManager(url, user: newAccountName, pass: newPassword)
        self.delegate?.networkManager?.sync()
        self.performSegue(withIdentifier: "logginSegue", sender: nil)
    }
}
