//
//  settingsView.swift
//  MyGate
//
//  Created by mitch on 2/22/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import UIKit

// spy delegate protocol
protocol SpyDelegate {
    func didFindWeaponOfMassDestruction(Address: String,Username: String, Password:String)
}

class settingsView: UIViewController, UITextFieldDelegate {
    // delegate
    var delegate : SpyDelegate?
    
    // user input textfields
    @IBOutlet weak var gateway: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    // label used to show user has no server socket
    @IBOutlet weak var errorlabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        //subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // show default user settings
        let defaults = UserDefaults.standard
        gateway.text = defaults.string(forKey: "serverAddress")
        password.text = defaults.string(forKey: "passwordName") ?? ""
        username.text = defaults.string(forKey: "usernameName") ?? ""
        self.gateway.delegate = self
        self.username.delegate = self
        self.password.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshLbl(notification:)), name: Notification.Name("NotificationIdentifier"), object: nil)

        
    }
    
    
    // Notify user no server settings are present
    @objc func refreshLbl(notification: NSNotification) {
        errorlabel.text = "Check settings"
        errorlabel.textColor = UIColor.red
    }
    
    /*
     func: viewWillDisappear
     input: bool
     output: none
     notes:
     - unsubscribe from keyboard notification
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //unsubscribeFromKeyboardNotifications()
    }
    
    
    // saves user settings in defaults
    // TODO change username and password to be saved in keychain
    @IBAction func doneEdit(_ sender: Any) {
        // save if user inputs are filled
        if delegate != nil || gateway.text != "" || password.text != "" || username.text != ""{
            //execute delegate for need user settings
            delegate?.didFindWeaponOfMassDestruction(Address: gateway.text! ,Username:username.text!, Password:password.text!)
            // save user settings
            let defaults = UserDefaults.standard
            defaults.set(gateway.text, forKey: "serverAddress")
            defaults.set(username.text, forKey: "usernameName")
            defaults.set(password.text, forKey: "passwordName")
            // dismiss the delegate
            dismiss(animated: true, completion: nil)
        }else{
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    // return will dismiss the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
