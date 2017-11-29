//
//  ViewController.swift
//  Qualifying Offers
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import UIKit

class RankViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /* UI Elements */
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var playerCollectionView: UICollectionView!
    
    /* Data Elements */
    var offers: [QualifyingOffer] {
        get {
            return (self.tabBarController as! TabViewController).offers
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.playerCollectionView.delegate = self
        self.playerCollectionView.dataSource = self
        
        self.playerCollectionView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.offers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Qualifying Offer Cell", for: indexPath) as! QualifyingOfferCell
        
        // UI Changes
        cell.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        
        cell.setOffer(offers[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30.0, height: 75.0)
    }
    
    


}

