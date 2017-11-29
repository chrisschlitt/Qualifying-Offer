//
//  LoadViewController.swift
//  Qualifying Offers
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadViewController: UIViewController {

    /* UI Elements */
    @IBOutlet weak var loadingViewContainer: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    
    /* Data Elements */
    var offers: [QualifyingOffer] = [QualifyingOffer]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let loadingView = NVActivityIndicatorView(frame: self.loadingViewContainer.bounds, type: .lineScale, color: UIColor.blue, padding: 30.0)
        self.loadingViewContainer.addSubview(loadingView)
        loadingView.startAnimating()
        
        self.loadingLabel.text = "Downloading Offers"
        
        download { (success, offers) in
            if(success) {
                self.offers = offers
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "Go to Stats", sender: self)
                }
            } else {
                print("Error Downloading Offers")
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Download a fresh set of qualifying offers
    private func download(_ completion: @escaping (Bool, [QualifyingOffer]) -> Void){
        let url = "https://questionnaire-148920.appspot.com/swe/"
        DataFetcher.fetch(url) { (success, data) in
            if(success){
                let offers = DataParser.parseQualifyingOffers(data)
                completion(true, offers)
            } else {
                completion(false, [QualifyingOffer]())
            }
        }
    }
    
    // Transfer the offer data to the tab view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let tabViewController = segue.destination as? TabViewController {
            tabViewController.offers = self.offers
        }
        
    }
    

}
