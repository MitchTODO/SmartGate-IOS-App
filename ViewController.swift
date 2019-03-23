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
    var password = String() // not used
    var username = String() // not used
    
    // buttons,ActivityIndicator
    @IBOutlet weak var spinWheel: UIActivityIndicatorView!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var open: UIButton!
    @IBOutlet weak var stop: UIButton!
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var Edit: UIBarButtonItem!
    
    // load user data
    func didFindWeaponOfMassDestruction(Address: String,Username: String, Password:String) {
        // Handle the save data
        ServerSocket = URL(string:Address)
        // these should be loaded from the keychain
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
    
    

    // post request to gateServer with the command the user selected
    func PostMaster(data: [String:Any],buttonName:UIButton) {
        // check user input is not nil mainly serverSocket
        if (ServerSocket != nil || password.isEmpty == false || username.isEmpty == false){
            
            // gate position is none and spinwheel is on
            position.text = ""
            self.spinWheel.isHidden = false
            
            // open,close,stop
            let parameters = data
            
            // create the url with URL
            // Serversocket is the url used to send the post
            let url = ServerSocket!

            // create the session object
            let session = URLSession.shared

            // now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "POST" //set http method as POST
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            } catch let error {
                print(error.localizedDescription)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            // create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        DispatchQueue.main.async {
                            buttonName.backgroundColor = UIColor.lightGray // turn button pressed back into gray
                            
                            self.position.text = "Gate Position: \(json["postion"] ?? "Connection Failed")"
                            
                            // change the buttons back to default view when a responce has been recevied
                            self.spinWheel.isHidden = true
                            self.close.isEnabled = true
                            self.open.isEnabled = true
                            self.open.backgroundColor = UIColor.lightGray // set other button color default gray
                            self.close.backgroundColor = UIColor.lightGray
                            
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            task.resume()
            
        // perform segue to the settings page
        // Set the notification on the settings page (red text on page)
        }else{
            performSegue(withIdentifier: "Ssettings", sender: Edit)
            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
        }
    }
 
    // Main get request to receive gate position
    func MasterGet(){
        let session = URLSession(configuration: .default)
        let getposition = session.dataTask(with: ServerSocket!) {(data,response,error) in
            if let e = error{
                print("Error Occurred: \(e)")
            } else {
                if (response as? HTTPURLResponse) != nil {
                    if let imageData = data {
                       
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                            // Get JSON
                            let json = try? JSONSerialization.jsonObject(with: imageData, options: [])
                            if let data = json as? [String: Any] {
                                
                                // JSON index
                                let ET = data["postion"] as? String
                                DispatchQueue.main.async {
                                    self.position.text = "Gate Position: \(ET ?? "Connection Failed")"
                                }
                            }
                        }
                        // if failed display connection failed
                    } else {
                        self.position.text = "Gate Position: Connection Failed"
                    }
                }else{
                     self.position.text = "Gate Position: Connection Failed"
                }
            }
            
        }
        getposition.resume()
    }
    
    // will disable buttons appropriately and change color
    func buttonManager(firstButton:UIButton,secondButton:UIButton){
        firstButton.backgroundColor = UIColor(red:0.0,green: 0.4,blue: 1.0, alpha: 0.5)
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
        self.close.backgroundColor = UIColor.lightGray // set other button color default gray
        self.stop.backgroundColor = UIColor(red:0.0,green: 0.4,blue: 1.0, alpha: 0.5) // stop button is blue
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



