//
//  DataParser.swift
//  Qualifying Offers
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import Foundation
import SwiftSoup

class DataParser {
    
    public static func parse(_ rawData: String) -> [QualifyingOffer] {
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

class QualifyingOffer: Comparable, CustomStringConvertible {
    
    let player: String
    let salary: Double
    
    var description: String {
        return self.player + ": " + self.salary.formatted
    }
    
    init(player: String, salary: String) {
        self.player = player.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let salaryValue = Double(salary.trimmingCharacters(in: .whitespacesAndNewlines).digits) {
            self.salary = salaryValue
        } else {
            self.salary = 0
        }
        
        
    }
    
    static func <(lhs: QualifyingOffer, rhs: QualifyingOffer) -> Bool {
        return lhs.salary < rhs.salary
    }
    
    static func ==(lhs: QualifyingOffer, rhs: QualifyingOffer) -> Bool {
        return lhs.salary == rhs.salary
    }
}

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}

extension Double {
    var formatted: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return "$" + numberFormatter.string(from: NSNumber(value: self))!
    }
}
