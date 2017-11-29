//
//  DataCollections.swift
//  Structured objects for mlb data
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import Foundation
import UIKit

// A qualifying offer for a new free agent
class QualifyingOffer: Comparable, CustomStringConvertible {
    
    // Data components
    let player: Player
    let salary: Double
    
    // String formatter
    var description: String {
        return self.player.firstName + " " + self.player.lastName + ": " + self.salary.formatted
    }
    
    // Initializer
    init(player: Player, salary: String) {
        self.player = player
        
        if let salaryValue = Double(salary.trimmingCharacters(in: .whitespacesAndNewlines).digits) {
            self.salary = salaryValue
        } else {
            self.salary = 0
        }
        
    }
    
    
    /* Comparable Functions */
    
    static func <(lhs: QualifyingOffer, rhs: QualifyingOffer) -> Bool {
        return lhs.salary < rhs.salary
    }
    
    static func ==(lhs: QualifyingOffer, rhs: QualifyingOffer) -> Bool {
        return lhs.salary == rhs.salary
    }
}

// A player connecter to the MLB API
class Player: Equatable {
    
    // Data components
    var firstName: String
    var lastName: String
    var playerId: Int
    var davenportCode: String
    var mlbCode: Int
    var retrosheetCode: String
    var image: UIImage?
    var inFocus: Bool = false
    
    init(firstName: String, lastName: String, playerId: Int, davenportCode: String, mlbCode: Int, retrosheetCode: String){
        self.firstName = firstName
        self.lastName = lastName
        self.playerId = playerId
        self.davenportCode = davenportCode
        self.mlbCode = mlbCode
        self.retrosheetCode = retrosheetCode
    }
    
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.firstName + " " + lhs.lastName == rhs.firstName + " " + rhs.lastName
    }
    
}
