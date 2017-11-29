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
    public static func parseQualifyingOffers(_ rawData: String) -> [QualifyingOffer] {
        var offers = [QualifyingOffer]()
        
        do {
            let parsedDocument: Document = try SwiftSoup.parse(rawData)
            
            let table: Element = try! parsedDocument.select("table").first()!
            let tableBody: Element = try! table.select("tbody").first()!
            
            for row: Element in tableBody.children() {
                let playerName = try! row.getElementsByClass("player-name").first()!.text()
                let playerSalary = try! row.getElementsByClass("player-salary").first()!.text()
                let qualifyingOffer = QualifyingOffer(player: playerName, salary: playerSalary)
                offers.append(qualifyingOffer)
            }
            
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("Unknown Error")
        }
        
        return offers
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
