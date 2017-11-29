//
//  ViewController.swift
//  Qualifying Offers
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let url = "https://questionnaire-148920.appspot.com/swe/"
        let data = DataFetcher.fetch(url) { (success, data) in
            let offers = DataParser.parse(data)
            
            print("Qualifying Offers:")
            for offer in offers {
                print(offer)
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

