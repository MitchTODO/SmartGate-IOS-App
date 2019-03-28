//
//  ViewController.swift
//  MyGate
//
//  Created by mitch on 2/4/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import UIKit
import Foundation

// accept the spyDelegate protocol
class ViewController: UIViewController,SpyDelegate,URLSessionDelegate {
    // placeholder for saved user variables
    var ServerSocket = URL(string:"")
    var password = String()
    var username = String()
    
    // outlets
    @IBOutlet weak var spinWheel: UIActivityIndicatorView!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var open: UIButton!
    @IBOutlet weak var stop: UIButton!
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var Edit: UIBarButtonItem!
    @IBOutlet weak var stackview: UIStackView!
    
    // change the buttons from a stack to horizontal proportional to screen orientation
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        switch UIDevice.current.orientation {
        case .portrait:
            self.stackview.axis = .vertical
        case .portraitUpsideDown:
            self.stackview.axis = .vertical
        case .landscapeLeft:
            self.stackview.axis = .horizontal
        case .landscapeRight:
            self.stackview.axis = .horizontal
        default:
            self.stackview.axis = .vertical
        }
    }
    // load user data
    func didFindWeaponOfMassDestruction(Address: String,Username: String, Password:String) {
        // Handle the save data
        ServerSocket = URL(string:Address)
        password = Password
        username = Username
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Ssettings" {
            let vc : settingsView = segue.destination as! settingsView
            vc.delegate = self
        }
    }
    
    // changes look to default
    func buttonDefault(){
        // change the buttons back to default
        self.spinWheel.isHidden = true
        self.close.isEnabled = true
        self.open.isEnabled = true
        self.open.backgroundColor = UIColor.lightGray // set other button color default gray
        self.close.backgroundColor = UIColor.lightGray
        self.stop.backgroundColor = UIColor.lightGray
        
    }
    
    
    // post request to gateServer with the command the user selected
    func PostMaster(data: [String:Any],buttonName:UIButton){
        // check user input is not empty
        if (ServerSocket != nil && password.isEmpty == false && username.isEmpty == false){
            // gate position is none and spinwheel is on
            position.text = ""
            self.spinWheel.isHidden = false
            
            // send post request
            var request = URLRequest(url: ServerSocket!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
            // create dataTask using the session object to send data to the server
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                // handle response with appropriate action
                if let error = error {
                    DispatchQueue.main.async {
                        buttonName.backgroundColor = UIColor.lightGray // turn button pressed back into gray
                        self.position.text = "Could not connect to the server."
                        self.buttonDefault()
                    }
                } else {
                    if let response = response as? HTTPURLResponse {
                        DispatchQueue.main.async {
                        if response.statusCode == 200 { // show JSON if response is successful
                            if let data = data {
                                DispatchQueue.main.async {
                                    //create json object from data
                                    let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                                    if let data = json as? [String: Any] {
                                        let position = data["postion"] as? String
                                        self.position.text = "Gate Position: \(position ?? "?" )"
                                    }
                                }
                            }
                        }else{
                            // show http error code
                            self.position.text = "Error Code: \(response.statusCode)"
                           }
                         self.buttonDefault()
                        }
                    }
                }
            }
            task.resume()
        // perform segue to the settings page
        // Set the notification on the settings page (red text on page)
         }else{
            self.buttonDefault()
            performSegue(withIdentifier: "Ssettings", sender: Edit)
            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
        }
    }

 
    // Main get request to receive gate position
    func MasterGet(){
        if (ServerSocket != nil || password.isEmpty == false || username.isEmpty == false){
        let session = URLSession(configuration: .default)
        let getposition = session.dataTask(with: ServerSocket!) {(data,response,error) in
            if let e = error{
                DispatchQueue.main.async {
                    self.position.text = "Could not connect to the server."
                }
            } else {
                if (response as? HTTPURLResponse) != nil {
                    if let imageData = data {
                       
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                            // Get JSON
                            let json = try? JSONSerialization.jsonObject(with: imageData, options: [])
                            if let data = json as? [String: Any] {
                                let ET = data["postion"] as? String
                                self.position.text = "Gate Position: \(ET ?? "Connection Failed")"
                            }
                        }
                    } else {
                        self.position.text = "No json data"
                    }
                }else{
                     self.position.text = "Connection Failed"
                }
            }
            
        }
        getposition.resume()
        }else{
            performSegue(withIdentifier: "Ssettings", sender: Edit)
            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
        }
    }
    

    // will disable buttons appropriately and change color
    func buttonManager(firstButton:UIButton,secondButton:UIButton){
        firstButton.backgroundColor = UIColor(red:1.0,green: 0.5,blue: 0.0, alpha: 0.5)
        firstButton.isEnabled = false
        secondButton.isEnabled = false
        secondButton.backgroundColor = UIColor.darkGray
    }
    
    // open button executes postmaster with open command
    @IBAction func OpenGate(_ sender: Any) {
        buttonManager(firstButton: open, secondButton: close)
        PostMaster(data: ["gate":"open","username":username,"password":password],buttonName: self.open)
    }
    // close button executes postmaster with close command
    @IBAction func CloseGate(_ sender: Any) {
        buttonManager(firstButton: close, secondButton: open)
        PostMaster(data: ["gate":"close","username":username,"password":password],buttonName: self.close)
    }
    // stop button executes postmaster with stop command
    @IBAction func StopGate(_ sender: Any) {
        buttonManager(firstButton: close, secondButton: open)
        self.open.backgroundColor = UIColor.lightGray // set other button color default gray
        self.close.backgroundColor = UIColor.lightGray
        self.stop.backgroundColor = UIColor(red:1.0,green: 0.5,blue: 0.0, alpha: 0.5) // stop button is orange
        PostMaster(data:["gate":"stop","username":username,"password":password],buttonName: self.stop)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // load user variables
        let defaults = UserDefaults.standard
        let server = defaults.string(forKey: "serverAddress")
        password = defaults.string(forKey: "passwordName") ?? ""
        username = defaults.string(forKey: "usernameName") ?? ""
        ServerSocket = URL(string:server ?? "")
        // make spin wheel bigger
        self.spinWheel.transform = CGAffineTransform(scaleX: 2, y: 2)
        // get gate position when app is launched
        MasterGet()
        // spin wheel is hidden
        self.spinWheel.isHidden = true
    }
}



