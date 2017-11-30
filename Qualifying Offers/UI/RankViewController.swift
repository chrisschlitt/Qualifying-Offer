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
    var salaries: [PlayerSalary] {
        get {
            return (self.tabBarController as! TabViewController).salaries
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.salaries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Player Cell", for: indexPath) as! PlayerCell
        
        // UI Changes
        cell.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        cell.playerImageView.image = UIImage(named: "placeholder.png")
        cell.setSalary(salaries[indexPath.row])
        cell.expanded = cell.salary.player.inFocus
        cell.playerHeatmapLoadingView.isHidden = false
        cell.playerStatsLabelA.text = ""
        cell.playerStatsLabelB.text = ""
        cell.playerHeatmapImageView.image = nil
        
        // Load the player image
        if(salaries[indexPath.row].player.image == nil){
            DataFetcher.fetchImage(salaries[indexPath.row].player) { (success, image) in
                if(success){
                    DispatchQueue.main.async {
                        self.salaries[indexPath.row].player.image = image!
                        if(cell.salary.player == self.salaries[indexPath.row].player){
                            cell.playerImageView.image = image!
                        }
                    }
                }
            }
        } else {
            cell.playerImageView.image = salaries[indexPath.row].player.image
        }
        
        // Load player stats
        if(cell.salary.player.inFocus && cell.salary.player.stats != nil){
            cell.playerStatsLabelA.text = "\(cell.salary.player.stats!.firstHalf)"
            cell.playerStatsLabelB.text = "\(cell.salary.player.stats!.secondHalf)"
        }
        
        // Load player heatmap
        if(cell.salary.player.inFocus && cell.salary.player.heatmap != nil){
            cell.playerHeatmapLoadingView.isHidden = true
            cell.playerHeatmapImageView.image = cell.salary.player.heatmap
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 75.0
        if let cell = collectionView.cellForItem(at: indexPath) as? PlayerCell {
            // Check if cell is expanded
            if(cell.salary.player.inFocus){
                height = 250.0
            }
        }
        
        return CGSize(width: collectionView.frame.width - 30.0, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Extract player
        let cell = collectionView.cellForItem(at: indexPath) as! PlayerCell
        let player = cell.salary.player
        player.inFocus = player.inFocus == false
        cell.expanded = player.inFocus
        
        if(cell.expanded && !player.statsRequested){
            player.statsRequested = true
            
            // Generate Heatmap
            DispatchQueue.global(qos: .background).async {
                let heatmap = HeatmapGenerator.generate()
                player.heatmap = heatmap
                DispatchQueue.main.async {
                    if let currentCell = (collectionView.cellForItem(at: indexPath) as? PlayerCell) {
                        if currentCell.salary.player == player {
                            // Update UI
                            currentCell.playerHeatmapLoadingView.isHidden = true
                            currentCell.playerHeatmapImageView.image = heatmap
                        }
                    }
                }
            }
            
            // Get Stats
            let url = "http://gd2.mlb.com/components/game/mlb/year_2016/pitchers/\(player.mlbCode).xml"
            
            DataFetcher.fetch(url, { (success, rawData) in
                if(success && rawData != "GameDay - 404 Not Found"){
                    
                    // Player is a pitcher
                    let stats = DataParser.parsePlayerStats(rawData)
                    player.stats = stats
                    player.type = .pitcher
                    
                    DispatchQueue.main.async {
                        let currentCell = (collectionView.cellForItem(at: indexPath) as! PlayerCell)
                        if currentCell.salary.player == player {
                            // Update UI
                            currentCell.playerStatsLabelA.text = "\(stats.firstHalf)"
                            currentCell.playerStatsLabelB.text = "\(stats.secondHalf)"
                        }
                    }
                } else {
                    // Batter Fallback
                    let url = "http://gd2.mlb.com/components/game/mlb/year_2016/batters/\(player.mlbCode).xml"
                    DataFetcher.fetch(url, { (success, rawData) in
                        if(success && rawData != "GameDay - 404 Not Found"){
                            // Player is a batter
                            let stats = DataParser.parsePlayerStats(rawData)
                            player.stats = stats
                            player.type = .batter
                            
                            DispatchQueue.main.async {
                                let currentCell = (collectionView.cellForItem(at: indexPath) as! PlayerCell)
                                if currentCell.salary.player == player {
                                    // Update UI
                                    currentCell.playerStatsLabelA.text = "\(stats.firstHalf)"
                                    currentCell.playerStatsLabelB.text = "\(stats.secondHalf)"
                                }
                            }
                        }
                    })
                }
                
            })
        } else if(cell.expanded && cell.salary.player.stats != nil){
            // Stats have already been downloaded
            cell.playerStatsLabelA.text = "\(cell.salary.player.stats!.firstHalf)"
            cell.playerStatsLabelB.text = "\(cell.salary.player.stats!.secondHalf)"
            if(cell.salary.player.heatmap != nil){
                cell.playerHeatmapLoadingView.isHidden = true
                cell.playerHeatmapImageView.image = cell.salary.player.heatmap
            } else {
                cell.playerHeatmapLoadingView.isHidden = false
            }
        }
        
        // Refresh cell
        cell.isSelected = false
        collectionView.reloadItems(at: [indexPath])
        
    }
    
}

