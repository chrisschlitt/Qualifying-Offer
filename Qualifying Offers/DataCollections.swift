//
//  DataCollections.swift
//  Structured objects for mlb data
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import Foundation

// A qualifying offer for a new free agent
class QualifyingOffer: Comparable, CustomStringConvertible {
    
    // Data components
    let firstName: String
    let lastName: String
    let salary: Double
    
    // String formatter
    var description: String {
        return self.firstName + " " + self.lastName + ": " + self.salary.formatted
    }
    
    // Initializer
    init(player: String, salary: String) {
        let playerName = player.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
        self.lastName = playerName[0]
        self.firstName = playerName[1]
        
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
