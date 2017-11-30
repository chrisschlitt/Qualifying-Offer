//
//  QualifyingOfferCell.swift
//  Qualifying Offers
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import UIKit

@IBDesignable
class PlayerCell: UICollectionViewCell {
    
    @IBInspectable
    public var cornerRadius: CGFloat = 3.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat = 2.0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
    
    // UI Flags
    var expanded = false
    var loading = false
    
    /* UI Elements */
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var playerNameView: UILabel!
    @IBOutlet weak var playerSalaryView: UILabel!
    @IBOutlet weak var playerStatsLabelA: UILabel!
    @IBOutlet weak var playerStatsLabelB: UILabel!
    @IBOutlet weak var playerHeatmapContainerView: UIView!
    @IBOutlet weak var playerHeatmapImageView: UIImageView!
    @IBOutlet weak var playerHeatmapLoadingView: UILabel!
    
    /* Data Elements */
    var salary: PlayerSalary!
    
    public func setSalary(_ offer: PlayerSalary) -> Void {
        self.salary = offer
        
        self.playerNameView.text = offer.player.firstName + " " + offer.player.lastName
        self.playerSalaryView.text = offer.salary.formatted
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.playerHeatmapImageView.clipsToBounds = true
        self.playerHeatmapImageView.layer.cornerRadius = 4.0
        self.playerHeatmapLoadingView.clipsToBounds = true
        self.playerHeatmapLoadingView.layer.cornerRadius = 4.0
        
        
        
        
        
        
    }
    
}
