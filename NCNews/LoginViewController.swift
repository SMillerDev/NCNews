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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pushConnect(_ sender: UIButton) {
        let url = urlField.text
        let oauthswift = OAuth2Swift(
            consumerKey:    "",
            consumerSecret: "",
            authorizeUrl:   url!+"/index.php/apps/oauth2/authorize",
            accessTokenUrl: url!+"/index.php/apps/oauth2/api/v1/token",
            responseType:   "code"
        )
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
        oauthswift.authorize(
            withCallbackURL: URL(string: "eu.seanmolenaar.NCNews://oauth-callback/nextcloud")!,
            scope: "profile", state:"NEXTCLOUD",
            success: { credential, response, parameters in
                print(credential.oauthToken)
                self.performSegue(withIdentifier: "logginSegue", sender: nil)
        },
            failure: { error in
                print(error.localizedDescription)
                self.errorText.text = error.localizedDescription
        }
        )
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let splitViewController = segue.destination as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        splitViewController.delegate = delegate
        
        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        controller.managedObjectContext = delegate.persistentContainer.viewContext
    }

}
