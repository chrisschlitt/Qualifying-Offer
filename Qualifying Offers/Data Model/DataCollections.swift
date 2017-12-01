//
//  DataCollections.swift
//  Structured objects for mlb data
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import Foundation
import UIKit

// A salary for a player
class PlayerSalary: Comparable, CustomStringConvertible {
    
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
    
    static func <(lhs: PlayerSalary, rhs: PlayerSalary) -> Bool {
        return lhs.salary < rhs.salary
    }
    
    static func ==(lhs: PlayerSalary, rhs: PlayerSalary) -> Bool {
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
    var stats: Stats?
    var type: PlayerType = .batter
    var statsRequested: Bool = false
    var heatmap: UIImage?
    var found: Bool
    
    init(firstName: String, lastName: String, playerId: Int, davenportCode: String, mlbCode: Int, retrosheetCode: String){
        self.firstName = firstName
        self.lastName = lastName
        self.playerId = playerId
        self.davenportCode = davenportCode
        self.mlbCode = mlbCode
        self.retrosheetCode = retrosheetCode
        self.found = true
    }
    
    static func notFound(firstName: String, lastName: String) -> Player {
        let player = Player(firstName: firstName, lastName: lastName, playerId: -1, davenportCode: "-1", mlbCode: -1, retrosheetCode: "-1")
        player.found = false
        return player
    }
    
    
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.firstName + " " + lhs.lastName == rhs.firstName + " " + rhs.lastName
    }
    
}

// Stats Wrapper
class Stats: CustomStringConvertible {
    // http://gd2.mlb.com/components/game/mlb/year_2007/batters/121358.xml
    
    let type: PlayerType
    var stats: [(String, String)] = [(String, String)]()
    
    init(type: PlayerType){
        self.type = type
    }
    
    func addStat(stat: String, value: String){
        self.stats.append((stat, value))
    }

    func getStat(stat: String) -> String? {
        for statTuple in stats {
            if statTuple.0 == stat {
                return statTuple.1
            }
        }
        return nil
    }
    
    var description: String {
        return getStatString(start: 0, end: stats.count)
    }
    
    var firstHalf: String {
        get {
            var middle = stats.count / 2
            if(stats.count % 2 != 0){
                middle += 1
            }
            
            return getStatString(start: 0, end: middle)
        }
    }
    
    var secondHalf: String {
        get {
            var middle = stats.count / 2
            if(stats.count % 2 != 0){
                middle += 1
            }
            
            return getStatString(start: middle, end: stats.count)
        }
    }
    
    private func getStatString(start: Int, end: Int) -> String {
        var statString = ""
        
        var count = 0
        for i in start..<end {
            let statTuple = stats[i]
            if(count > 0){
            statString += "\n"
            }
            statString += statTuple.0 + ": " + statTuple.1
            count += 1
        }
        
        return statString
    }
    
}

enum PlayerType: String {
    case pitcher = "pitcher"
    case batter = "batter"
    
    var description: String {
        return self.rawValue
    }
    
}
