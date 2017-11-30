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
    var salaries: [PlayerSalary] = [PlayerSalary]()
    var qualifyingOffer: Double = 0.0
    
    var isInitialLoad: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // UI Changes
        let loadingView = NVActivityIndicatorView(frame: self.loadingViewContainer.bounds, type: .lineScale, color: UIColor.fromHex("2662B5"), padding: 30.0)
        self.loadingViewContainer.addSubview(loadingView)
        loadingView.startAnimating()
        self.loadingLabel.font = UIFont(name: "Lato-Bold", size: 18.0)
        self.loadingLabel.text = "Downloading Player Index"
        
        // Download the player dictionary
        self.downloadPlayerDictionary { (success, playerDictionary) in
            if(success){
                self.playerDictionary = playerDictionary
                DispatchQueue.main.async {
                    self.loadingLabel.text = "Downloading Salaries"
                }
                
                // Download the salaries
                self.download { (success, salaries) in
                    if(success) {
                        self.salaries = salaries
                        
                        // Go to the tab view controller
                        DispatchQueue.main.async {
                            if(self.isInitialLoad){
                                self.performSegue(withIdentifier: "Go to Stats", sender: self)
                            } else {
                                self.performSegue(withIdentifier: "Unwind from Load", sender: self)
                            }
                            
                        }
                    } else {
                        print("Error Downloading Salaries")
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
    
    // Download a fresh set of salaries
    private func download(_ completion: @escaping (Bool, [PlayerSalary]) -> Void){
        let url = "https://questionnaire-148920.appspot.com/swe/"
        DataFetcher.fetch(url) { (success, data) in
            if(success){
                
                // Calculate qualifying offer
                let salaries = DataParser.parseSalaries(data, players: self.playerDictionary)
                let topSalaries = Array(salaries.sorted(by: >)[0..<125])
                
                var qualifyingOffer = 0.0
                var count = 0
                for salary in topSalaries {
                    qualifyingOffer += salary.salary
                    count += 1
                }
                
                let rawQualifyingOfferValue = qualifyingOffer / Double(count)
                
                self.qualifyingOffer = Double(round(rawQualifyingOfferValue * 100)/100)
                
                completion(true, topSalaries)
            } else {
                completion(false, [PlayerSalary]())
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
            tabViewController.salaries = self.salaries
            tabViewController.qualifyingOffer = self.qualifyingOffer
        } else if let settingsViewController = (segue.destination as? SettingsViewController) {
            let tabViewController = settingsViewController.tabBarController as! TabViewController
            tabViewController.salaries = self.salaries
            tabViewController.qualifyingOffer = self.qualifyingOffer
        }
    }
    

}
