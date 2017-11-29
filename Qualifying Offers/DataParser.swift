//
//  DataParser.swift
//  Handles parsing raw data into structured objects
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import Foundation
import SwiftSoup

class DataParser {
    
    // Parse the qualifying offers page
    public static func parseQualifyingOffers(_ rawData: String, players: [String:Player]) -> [QualifyingOffer] {
        var offers = [QualifyingOffer]()
        
        do {
            let parsedDocument: Document = try SwiftSoup.parse(rawData)
            
            let table: Element = try! parsedDocument.select("table").first()!
            let tableBody: Element = try! table.select("tbody").first()!
            
            for row: Element in tableBody.children() {
                let playerNameRaw = try! row.getElementsByClass("player-name").first()!.text()
                let playerSalaryRaw = try! row.getElementsByClass("player-salary").first()!.text()
                
                // Extract Name
                let playerNameComponents = playerNameRaw.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
                let lastName = playerNameComponents[0]
                let firstName = playerNameComponents[1]
                
                if let player = players[firstName + " " + lastName] {
                    let qualifyingOffer = QualifyingOffer(player: player, salary: playerSalaryRaw)
                    offers.append(qualifyingOffer)
                }
            }
            
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("Unknown Error")
        }
        
        return offers
    }
    
    // Parse Player Information
    public static func parsePlayerIdentifications(_ rawData: String) -> [String:Player] {
        var players = [String:Player]()
        
        let rows = rawData.components(separatedBy: "\n")
        for i in 1..<rows.count {
            print(rows[i])
            
            let rowValues = rows[i].replacingOccurrences(of: "\"", with: "").components(separatedBy: ",")
            
            if(rowValues.count != 6){
                continue
            }
            
            let firstName = rowValues[1]
            let lastName = rowValues[0]
            var playerId = 0
            if let playerIdInt = Int(rowValues[2]) {
                playerId = playerIdInt
            }
            let davenportCode = rowValues[3]
            var mlbCode = 0
            if let mlbCodeInt = Int(rowValues[4]) {
                mlbCode = mlbCodeInt
            }
            let retrosheetCode = rowValues[5]
            
            let playerIdentification = Player(firstName: firstName, lastName: lastName, playerId: playerId, davenportCode: davenportCode, mlbCode: mlbCode, retrosheetCode: retrosheetCode)
            players[firstName + " " + lastName] = playerIdentification
        }
        
        return players
    }
    
}


/* Primitive Helper Extensions */

extension String {
    // Extract only the digits from a string
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}

extension Double {
    // Format a double into a salary
    var formatted: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return "$" + numberFormatter.string(from: NSNumber(value: self))!
    }
}
