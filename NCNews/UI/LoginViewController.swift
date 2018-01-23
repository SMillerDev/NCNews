//
//  LoginViewController.swift
//  NCNews
//
//  Created by Sean Molenaar on 10/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import OAuthSwift

class LoginViewController: UIViewController {
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var errorText: UILabel!

    @IBOutlet weak var oauthView: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    @IBOutlet weak var secretField: UITextField!
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    var passwordItems: [KeychainPasswordItem] = []
    var views: [UIView] = []

    weak var delegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.barTintColor = NCColor.custom
        urlField.text = UserDefaults.standard.url(forKey: DefaultConstants.url)?.absoluteString
        views = [loginView, oauthView]
        secretField.text = UserDefaults.standard.string(forKey: DefaultConstants.authKey)
        userField.text = UserDefaults.standard.string(forKey: DefaultConstants.username)
        UserDefaults.standard.removeObject(forKey: DefaultConstants.authKey)
    }
    @IBAction func didFinishEditingURL(_ sender: Any) {
        NetworkManager.getColor(url: urlField.text!, completionHandler: { color in
            self.navBar.barTintColor = color
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        let hasLoginKey = UserDefaults.standard.bool(forKey: DefaultConstants.didLogin)
        if hasLoginKey {
            //Already logged in, continuing
            if let user = UserDefaults.standard.string(forKey: DefaultConstants.username), !user.isEmpty {
                self.basicAuth(UserDefaults.standard.url(forKey: DefaultConstants.url)!, user: user)
                return
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func changeLoginOption(_ sender: Any) {
        for view in views {
            view.isHidden = views.index(of: view) != segmentControl.selectedSegmentIndex
        }
    }

    @IBAction func pushConnect(_ sender: UIButton) {
        guard let urlText = urlField.text, let url = URL(string: urlText), !urlText.isEmpty else {
            let alertView = UIAlertController(title: "Login Problem",
                                              message: "Invalid URL entered",
                                              preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertView.addAction(okAction)
            present(alertView, animated: true, completion: nil)
            return
        }
        UserDefaults.standard.set(url, forKey: DefaultConstants.url)
        if segmentControl.selectedSegmentIndex == 0 {
            self.basicAuth(url)
            return
        }
        self.oauthLogin(url)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let splitViewController = segue.destination as? UISplitViewController
        let navigationController = splitViewController?.viewControllers[(splitViewController?.viewControllers.count)!-1] as? UINavigationController
        navigationController?.topViewController!.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        splitViewController?.delegate = delegate
    }

    func reportError(error: String, alert: Bool) {
        if !alert {
            errorText.text = error
            return
        }
        let alertView = UIAlertController(title: "Login Problem",
                                          message: error,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(okAction)
        present(alertView, animated: true, completion: nil)
    }
}
