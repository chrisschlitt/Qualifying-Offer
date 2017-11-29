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
    @IBOutlet weak var playerCollectionView: UICollectionView!
    @IBOutlet weak var qualifyingOfferView: UIView!
    @IBOutlet weak var qualifyingOfferValueLabel: UILabel!
    @IBOutlet weak var qualifyingOfferLabel: UILabel!
    
    /* Data Elements */
    var offers: [QualifyingOffer] {
        get {
            return (self.tabBarController as! TabViewController).offers
        }
    }
    var qualifyingOffer: Double {
        get {
            return (tabBarController as! TabViewController).qualifyingOffer
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.qualifyingOfferValueLabel.text = self.qualifyingOffer.formatted
        self.qualifyingOfferView.layer.borderColor = UIColor.darkGray.cgColor
        self.qualifyingOfferView.layer.borderWidth = 1.5
        
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
        cell.expanded = false
        cell.playerImageView.image = UIImage(named: "placeholder.png")
        
        cell.setOffer(offers[indexPath.row])

        if(offers[indexPath.row].player.image == nil){
            DataFetcher.fetchImage(offers[indexPath.row].player) { (success, image) in
                if(success){
                    DispatchQueue.main.async {
                        self.offers[indexPath.row].player.image = image!
                        if(cell.offer.player == self.offers[indexPath.row].player){
                            cell.playerImageView.image = image!
                            collectionView.reloadItems(at: [indexPath])
                        }
                    }
                }
            }
        } else {
            cell.playerImageView.image = offers[indexPath.row].player.image
        }
        
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        var height: CGFloat = 75.0
        
        if let cell = collectionView.cellForItem(at: indexPath) as? QualifyingOfferCell {
            if(cell.expanded){
                height = 300.0
            }
        }
        
        return CGSize(width: collectionView.frame.width - 30.0, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! QualifyingOfferCell  // or whatever you collection view cell class name is.
        
        cell.offer.player.inFocus = cell.offer.player.inFocus == false
        cell.expanded = cell.offer.player.inFocus
        print("Set to \(cell.expanded)")
        cell.isSelected = false
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    


}

