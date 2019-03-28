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

    @IBOutlet weak var Open: WKInterfaceButton!
    
    @IBOutlet weak var Stop: WKInterfaceButton!
    
    @IBOutlet weak var Close: WKInterfaceButton!
    

    func masterPost(data: [String:Any],buttonName:WKInterfaceButton){
        let serverSocket = URL(string:"")!
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
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
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
        masterPost(data:["gate":"open"],buttonName:Open)
    }
    
    @IBAction func stop() {
        masterPost(data:["gate":"stop"],buttonName:Stop)
    }
    
    @IBAction func close() {
        masterPost(data:["gate":"close"],buttonName:Close)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
