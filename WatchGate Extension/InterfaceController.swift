//
//  InterfaceController.swift
//  WatchGate Extension
//
//  Created by mitch on 3/24/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    let serverSocket = URL(string:"<YOUR URL>")!
    @IBOutlet weak var Open: WKInterfaceButton!
    @IBOutlet weak var Stop: WKInterfaceButton!
    @IBOutlet weak var Close: WKInterfaceButton!
    
    // Main get request to receive gate position
    func MasterGet(){
            let session = URLSession(configuration: .default)
        let getposition = session.dataTask(with: serverSocket) {(data,response,error) in
            
                    if (response as? HTTPURLResponse) != nil {
                        if let imageData = data {
                            DispatchQueue.main.async { // Make sure you're on the main thread here
                                // Get JSON
                                let json = try? JSONSerialization.jsonObject(with: imageData, options: [])
                                if let data = json as? [String: Any] {
                                    let ET = data["postion"] as? String
                                    
                                    if ET == "18"{
                                        self.Open.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.5))
                                        
                                    }else if ET == "0"{
                                        self.Close.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.5))
                                    }else{
                                        self.Open.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.5))
                                        self.Close.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.5))
                                    }
                                }
                            }
                        } else {
                           
                        }
                    }
                }
                
        
            getposition.resume()
    }
    

    func masterPost(data: [String:Any],buttonName:WKInterfaceButton){
        
        var request = URLRequest(url: serverSocket)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data {
                    DispatchQueue.main.async {
                        //create json object from data
                        let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                        if let data = json as? [String: Any] {
                            let ET = data["postion"] as? String
                            if ET == "18"{
                                self.Open.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.5))
                                self.Close.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.2))
                                self.Stop.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.2))
                            }else if ET == "0"{
                                self.Close.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.5))
                                self.Open.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.2))
                                self.Stop.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.2))
                            }else{
                                self.Open.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.5))
                                self.Close.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.5))
                                self.Stop.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.2))
                            }
                        }
                    }
                }
                
            }
        }
        task.resume()
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    
    @IBAction func open() {
        masterPost(data:["gate":"open","username":"<YOUR USERNAME>","password":"YOURPASSWORD"],buttonName:Open)
        Open.setBackgroundColor(UIColor(red:1.0,green: 0.5,blue: 0.0, alpha: 0.5))
    }
    
    @IBAction func stop() {
        masterPost(data:["gate":"stop","username":"<YOUR USERNAME>","password":"YOURPASSWORD"],buttonName:Stop)
        Stop.setBackgroundColor(UIColor(red:1.0,green: 0.5,blue: 0.0, alpha: 0.5))
    }
    
    @IBAction func close() {
        masterPost(data:["gate":"close","username":"<YOUR USERNAME>","password":"YOURPASSWORD"],buttonName:Close)
        Close.setBackgroundColor(UIColor(red:1.0,green: 0.5,blue: 0.0, alpha: 0.5))
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        MasterGet()
        self.Close.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.2))
        self.Open.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.2))
        self.Stop.setBackgroundColor(UIColor(red:1.0,green: 1.0,blue: 1.0, alpha: 0.2))
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
