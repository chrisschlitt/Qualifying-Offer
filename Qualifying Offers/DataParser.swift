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
    
    // Parse the salaries page
    public static func parseSalaries(_ rawData: String, players: [String:Player]) -> [PlayerSalary] {
        var salaries = [PlayerSalary]()
        
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
                    let salary = PlayerSalary(player: player, salary: playerSalaryRaw)
                    salaries.append(salary)
                }
            }
            
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("Unknown Error")
        }
        
        return salaries
    }
    
    // Parse Player Information
    public static func parsePlayerIdentifications(_ rawData: String) -> [String:Player] {
        var players = [String:Player]()
        
        let rows = rawData.components(separatedBy: "\n")
        for i in 1..<rows.count {
            
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
    
    // Parse Player Stats
    public static func parsePlayerStats(_ rawData: String) -> Stats {
        var stats = Stats(type: .batter)
        
        do {
            let parsedDocument: Document = try SwiftSoup.parse(rawData, "", Parser.xmlParser())
            if let statsTag = try! parsedDocument.getElementsByTag("batting").first() {
                stats.addStat(stat: "AB", value: try! statsTag.attr("s_ab"))
                stats.addStat(stat: "HR", value: try! statsTag.attr("s_hr"))
                stats.addStat(stat: "RBI", value: try! statsTag.attr("s_rbi"))
                stats.addStat(stat: "H", value: try! statsTag.attr("s_h"))
                stats.addStat(stat: "SB", value: try! statsTag.attr("s_sb"))
                stats.addStat(stat: "AVG", value: try! statsTag.attr("avg"))
                stats.addStat(stat: "R", value: try! statsTag.attr("s_r"))
                stats.addStat(stat: "1B", value: try! statsTag.attr("s_single"))
                stats.addStat(stat: "2B", value: try! statsTag.attr("s_double"))
                stats.addStat(stat: "3B", value: try! statsTag.attr("s_triple"))
                stats.addStat(stat: "BB", value: try! statsTag.attr("s_bb"))
                stats.addStat(stat: "K", value: try! statsTag.attr("s_so"))
            } else if let statsTag = try! parsedDocument.getElementsByTag("pitching").first() {
                stats = Stats(type: .pitcher)
                stats.addStat(stat: "IP", value: try! statsTag.attr("s_ip"))
                stats.addStat(stat: "H", value: try! statsTag.attr("s_h"))
                stats.addStat(stat: "ER", value: try! statsTag.attr("s_er"))
                stats.addStat(stat: "R", value: try! statsTag.attr("s_r"))
                stats.addStat(stat: "BB", value: try! statsTag.attr("s_bb"))
                stats.addStat(stat: "K", value: try! statsTag.attr("s_k"))
                stats.addStat(stat: "SV", value: try! statsTag.attr("s_sv"))
            }
            
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("Unknown Error")
        }
        
        return stats
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
