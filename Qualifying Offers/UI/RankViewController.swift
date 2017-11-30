//
//  ViewController.swift
//  Qualifying Offers
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import UIKit
import PopupDialog

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
        
        // Add the heatmap gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RankViewController.heatmapTapped(_:)))
        cell.playerHeatmapImageView.isUserInteractionEnabled = true
        cell.playerHeatmapImageView.tag = indexPath.row
        if cell.playerHeatmapImageView.gestureRecognizers == nil || cell.playerHeatmapImageView.gestureRecognizers?.count == 0 {
            cell.playerHeatmapImageView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        
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
    
    @objc func heatmapTapped(_ sender: AnyObject) {
        // Determine Player
        let player = salaries[sender.view.tag].player
        
        if(player.heatmap == nil){
            return
        }
        
        // Prepare the popup assets
        let title = "\(player.firstName) \(player.lastName)"
        var message = "Hitting Heatmap"
        if(player.type == .pitcher){
            message = "Opposing Hitters Heatmap"
        }
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, image: player.heatmap)
        self.present(popup, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Extract player
        let cell = collectionView.cellForItem(at: indexPath) as! PlayerCell
        let player = cell.salary.player
        player.inFocus = player.inFocus == false
        cell.expanded = player.inFocus
        
        if(cell.expanded && !player.statsRequested){
            player.statsRequested = true
            
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
                    player.type = .batter
                    let url = "http://gd2.mlb.com/components/game/mlb/year_2016/batters/\(player.mlbCode).xml"
                    DataFetcher.fetch(url, { (success, rawData) in
                        if(success && rawData != "GameDay - 404 Not Found"){
                            // Player is a batter
                            let stats = DataParser.parsePlayerStats(rawData)
                            player.stats = stats
                            
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
                
                
                
                
                // Generate Heatmap
                var heatmapUrl = "http://www.brooksbaseball.net/plot_h_profile.php?s_type=2&gFilt=&pFilt=FA|SI|FC|CU|SL|CS|KN|CH|FS|SB&time=month&player=\(player.mlbCode)&startDate=01/01/2016&endDate=12/30/2016&minmax=ci&var=baa&balls=-1&strikes=-1&b_hand=-1"
                if(player.type == .pitcher){
                    heatmapUrl = "http://www.brooksbaseball.net/plot_profile.php?s_type=2&gFilt=&pFilt=FA|SI|FC|CU|SL|CS|KN|CH|FS|SB&time=month&player=\(player.mlbCode)&startDate=01/01/2016&endDate=12/30/2016&minmax=ci&var=baa&balls=-1&strikes=-1&b_hand=-1"
                }
                DataFetcher.fetchImage(heatmapUrl, { (success, image) in
                    if(success){
                        player.heatmap = image
                        DispatchQueue.main.async {
                            if let currentCell = (collectionView.cellForItem(at: indexPath) as? PlayerCell) {
                                if currentCell.salary.player == player {
                                    // Update UI
                                    currentCell.playerHeatmapLoadingView.isHidden = true
                                    currentCell.playerHeatmapImageView.image = player.heatmap
                                }
                            }
                        }
                        
                    }
                })
                
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

