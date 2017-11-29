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
    var playerDictionary: [String:Player] = [String:Player]()
    var offers: [QualifyingOffer] = [QualifyingOffer]()
    var qualifyingOffer: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let loadingView = NVActivityIndicatorView(frame: self.loadingViewContainer.bounds, type: .lineScale, color: UIColor.blue, padding: 30.0)
        self.loadingViewContainer.addSubview(loadingView)
        loadingView.startAnimating()
        
        self.loadingLabel.text = "Downloading Player Index"
        
        downloadPlayerDictionary { (success, playerDictionary) in
            if(success){
                self.playerDictionary = playerDictionary
                
                DispatchQueue.main.async {
                    self.loadingLabel.text = "Downloading Offers"
                }
                self.download { (success, offers) in
                    if(success) {
                        self.offers = offers
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "Go to Stats", sender: self)
                        }
                    } else {
                        print("Error Downloading Offers")
                    }
                    
                }
            } else {
                print("Error Downloading Player Index")
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
                let offers = DataParser.parseQualifyingOffers(data, players: self.playerDictionary)
                let topOffers = Array(offers.sorted(by: >)[0..<150])
                
                var qualifyingOffer = 0.0
                var count = 0
                for offer in topOffers {
                    qualifyingOffer += offer.salary
                    count += 1
                }
                
                self.qualifyingOffer = qualifyingOffer / Double(count)
                
                completion(true, topOffers)
            } else {
                completion(false, [QualifyingOffer]())
            }
        }
    }
    
    // Download the player dictionary
    private func downloadPlayerDictionary(_ completion: @escaping (Bool, [String:Player]) -> Void){
        let url = "http://legacy.baseballprospectus.com/sortable/playerids/playerid_list.csv"
        DataFetcher.fetch(url) { (success, data) in
            if(success){
                DispatchQueue.main.async {
                    self.loadingLabel.text = "Parsing Player Index"
                }
                let players = DataParser.parsePlayerIdentifications(data)
                completion(true, players)
            } else {
                completion(false, [String:Player]())
            }
        }
    }
    
    // Transfer the offer data to the tab view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let tabViewController = segue.destination as? TabViewController {
            tabViewController.offers = self.offers
            tabViewController.qualifyingOffer = self.qualifyingOffer
        }
        
    }
    

}
