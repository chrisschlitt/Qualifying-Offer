//
//  DataFetcher.swift
//  Handles downloading data from the internet
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import Foundation

class DataFetcher {
    // Fetch remote data
    static func fetch(_ endpoint: String, _ completion: @escaping (Bool, String) -> Void){
        let baseURL = URL(string: endpoint)!
        
        // Create the URL Session object and connection to the server
        let task = URLSession.shared.dataTask(with: baseURL) { (data, response, error) in
            
            if(error != nil){
                completion(false, error!.localizedDescription)
            }
            
            if let stingData = String(data: data!, encoding: .utf8) {
                completion(true, stingData)
            } else {
                completion(false, "Could not generate string")
            }
        }
        // Run the request
        task.resume()
        
    }
    
}
