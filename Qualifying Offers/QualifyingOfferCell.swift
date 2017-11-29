//
//  QualifyingOfferCell.swift
//  Qualifying Offers
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import UIKit

@IBDesignable
class QualifyingOfferCell: UICollectionViewCell {
    
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
    
    var expanded = false
    var loading = false
    
    /* UI Elements */
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var playerNameView: UILabel!
    @IBOutlet weak var playerSalaryView: UILabel!
    
    /* Data Elements */
    var offer: QualifyingOffer!
    
    public func setOffer(_ offer: QualifyingOffer) -> Void {
        self.offer = offer
        
        self.playerNameView.text = offer.player.firstName + " " + offer.player.lastName
        self.playerSalaryView.text = offer.salary.formatted
        self.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
}
