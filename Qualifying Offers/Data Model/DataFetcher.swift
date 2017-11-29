//
//  DataFetcher.swift
//  Handles downloading data from the internet
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import Foundation
import UIKit

class DataFetcher {
    
    // Fetch remote data
    static func fetch(_ endpoint: String, _ completion: @escaping (Bool, String) -> Void){
        print("Fetching: " + endpoint)
        let baseURL = URL(string: endpoint)!
        
        // Create the URL Session object and connection to the server
        let task = URLSession.shared.dataTask(with: baseURL) { (data, response, error) in
            
            if(error != nil){
                print(error!.localizedDescription)
                completion(false, error!.localizedDescription)
            }
            
            if let stringData = String(data: data!, encoding: .utf8) {
                completion(true, stringData)
            } else if let stringData = String(data: data!, encoding: .ascii) {
                completion(true, stringData)
            } else {
                print("Could not generate string")
                completion(false, "Could not generate string")
            }
        }
        // Run the request
        task.resume()
        
    }
    
    // Fetch Image
    static func fetchImage(_ player: Player, _ completion: @escaping (Bool, UIImage?) -> Void){
        
        let endpoint = "http://gdx.mlb.com/images/gameday/mugshots/mlb/\(player.mlbCode)@4x.jpg"
        
        let baseURL = URL(string: endpoint)!
        
        // Create the URL Session object and connection to the server
        let task = URLSession.shared.dataTask(with: baseURL) { (data, response, error) in
            
            if(error != nil){
                completion(false, nil)
            }
            
            if let image = UIImage(data: data!) {
                completion(true, image)
            } else {
                completion(false, nil)
            }
            
            
        }
        // Run the request
        task.resume()
        
    }
}
