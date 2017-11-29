//
//  HeatmapGenerator.swift
//  Qualifying Offers
//
//  Created by Christopher Schlitt on 11/29/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import Foundation
import UIKit

class HeatmapGenerator {
    
    public static func generate() -> UIImage {
        // Import hit and strike data for Maikel Franco (3rd Baseman for the Philadelphia Phillies)
        let hits = CSVLoader.loadData(csv: "FrancoHits")
        let strikes = CSVLoader.loadData(csv: "FrancoStrikes")
        
        /*
         * Define how detailed the resulting view will be
         * In the form of a "box size" between 1 and 100
         * and a divisor of 100
         */
        let detailed = 5
        let numberOfBoxes = 100 / detailed
        let hitColor = UIColor.red
        let strikeColor = UIColor.blue
        let neutralColor = UIColor.blend(color1: hitColor, intensity1: 0.5, color2: strikeColor, intensity2: 0.5)
        
        // Initialize the batter's box data
        var battersBoxData = [[Int]]()
        for _ in 0..<numberOfBoxes {
            var row = [Int]()
            for _ in 0..<numberOfBoxes{
                row.append(0)
            }
            battersBoxData.append(row)
        }
        
        // Generate the batter's box data
        // Note: This is built to account for different numbers of hits and strikes
        for hit in hits {
            let boxX = hit[0] / (100 / numberOfBoxes)
            let boxY = hit[1] / (100 / numberOfBoxes)
            battersBoxData[boxX][boxY] += 1
        }
        for strike in strikes {
            let boxX = strike[0] / (100 / numberOfBoxes)
            let boxY = strike[1] / (100 / numberOfBoxes)
            battersBoxData[boxX][boxY] -= 1
        }
        
        // Calculate the max and min box score
        var maxScore = 0
        var minScore = 0
        for i in 0..<numberOfBoxes {
            for ii in 0..<numberOfBoxes {
                if(battersBoxData[i][ii] < minScore){
                    minScore = battersBoxData[i][ii]
                }
                if(battersBoxData[i][ii] > maxScore){
                    maxScore = battersBoxData[i][ii]
                }
            }
        }
        
        // Create the batters box view
        var battersBoxViews = [[UIView]]()
        var battersBoxView: UIStackView!
        DispatchQueue.main.sync {
            battersBoxView = UIStackView(frame: CGRect(x: 25, y: 50, width: 100, height: 100))
            battersBoxView.distribution = .fillEqually
            battersBoxView.axis = .vertical
            battersBoxView.backgroundColor = UIColor.groupTableViewBackground
        }
        // let battersBoxView = UIStackView(frame: CGRect(x: 25, y: 50, width: 100, height: 100))
        
        
        // Iterate over the data and create the batters box view
        for i in 0..<numberOfBoxes {
            // Create the view for the row
            var rowView: UIStackView!
            DispatchQueue.main.sync {
                rowView = UIStackView(frame: CGRect(x: 0, y: (i * numberOfBoxes), width: 100, height: (100 / numberOfBoxes)))
                rowView.distribution = .fillEqually
                rowView.axis = .horizontal
            }
            
            
            
            var battersBoxViewsRow = [UIView]()
            
            // Iterate over each cell in the row
            for ii in 0..<numberOfBoxes {
                
                // Create the cell
                var cellView: UIView!
                DispatchQueue.main.sync {
                    cellView = UIView(frame: CGRect(x: (CGFloat(ii) * CGFloat(100.0/CGFloat(numberOfBoxes))), y: (CGFloat(i) * CGFloat(100.0 / CGFloat(numberOfBoxes))), width: CGFloat(100.0 / CGFloat(numberOfBoxes)), height: CGFloat(100.0 / CGFloat(numberOfBoxes))))
                    cellView.clipsToBounds = true
                }
                
                // Color the cell based on the cell's score
                if(battersBoxData[i][ii] > 0){
                    // Calculate shade of red
                    let shadeIntensity = CGFloat(battersBoxData[i][ii]) / CGFloat(maxScore)
                    
                    let boxColor = UIColor.blend(color1: hitColor, intensity1: shadeIntensity, color2: neutralColor, intensity2: (1.0 - shadeIntensity))
                    DispatchQueue.main.sync {
                        cellView.backgroundColor = boxColor
                    }
                } else if(battersBoxData[i][ii] < 0){
                    // Calculate shade of blue
                    let shadeIntensity = CGFloat(abs(battersBoxData[i][ii])) / CGFloat(abs(minScore))
                    
                    let boxColor = UIColor.blend(color1: strikeColor, intensity1: shadeIntensity, color2: neutralColor, intensity2: (1.0 - shadeIntensity))
                    DispatchQueue.main.sync {
                        cellView.backgroundColor = boxColor
                    }
                } else {
                    // Neutral cell
                    DispatchQueue.main.sync {
                        cellView.backgroundColor = neutralColor
                    }
                }
                
                // Add the cell to the row
                DispatchQueue.main.sync {
                    cellView.tag = ii
                    rowView.addArrangedSubview(cellView)
                }
                battersBoxViewsRow.append(cellView)
            }
            // Add the row to the view
            DispatchQueue.main.sync {
                rowView.tag = i
                battersBoxView.addArrangedSubview(rowView)
                battersBoxViews.append(battersBoxViewsRow)
            }
        }
        
        // Display the batters box view
        // PlaygroundPage.current.liveView = battersBoxView
        
        // Raw colored batter's box view
        // battersBoxView
        
        
        // Iterate over each box and add gradients between diagional neighboring boxes
        for i in 0..<battersBoxViews.count {
            for ii in 0..<battersBoxViews[i].count {
                let battersBoxViewRef = battersBoxViews[i][ii]
                
                // Iterate over the diagional neighboring boxes
                var referenceColors: [[Int]] = [[-1, -1], [1, -1], [1, 1], [-1, 1]]
                for j in 0..<referenceColors.count {
                    // Correct edge cases
                    if(referenceColors[j][0] + ii < 0){
                        referenceColors[j][0] = 0
                    } else if (referenceColors[j][0] + ii >= battersBoxViews[i].count){
                        referenceColors[j][0] = 0
                    }
                    if(referenceColors[j][1] + i < 0){
                        referenceColors[j][1] = 0
                    } else if(referenceColors[j][1] + i >= battersBoxViews.count){
                        referenceColors[j][1] = 0
                    }
                    
                    // Get adjacent cells
                    let adjX1 = referenceColors[j][0]
                    let adjY1 = 0
                    let adjX2 = 0
                    let adjY2 = referenceColors[j][1]
                    
                    // Create the compound target color
                    var mixedColor: UIColor!
                    DispatchQueue.main.sync {
                        let colorA = UIColor.blend(color1: battersBoxViewRef.backgroundColor!, color2: battersBoxViews[referenceColors[j][1] + i][referenceColors[j][0] + ii].backgroundColor!)
                        let colorB = UIColor.blend(color1: battersBoxViews[adjY1 + i][adjX1 + ii].backgroundColor!, color2: battersBoxViews[adjY2 + i][adjX2 + ii].backgroundColor!)
                        mixedColor = UIColor.blend(color1: colorA, color2: colorB)
                    }
                    // Calculate the size of the shaded box
                    var sideLength: CGFloat!
                    var additionalDistance: CGFloat!
                    DispatchQueue.main.sync {
                        sideLength = CGFloat((Double(((battersBoxViewRef.frame.width / 2.0) * (battersBoxViewRef.frame.width / 2.0)) / 2.0).squareRoot()) * 2.0)
                        additionalDistance = (sideLength - (battersBoxViewRef.frame.width / 2.0)) / 2.0
                    }
                    
                    // Create gradient view
                    var gradientView: UIView!
                    DispatchQueue.main.sync {
                        if(j == 0){
                            gradientView = UIView(frame: CGRect(x: 0.0 - additionalDistance, y: 0.0 - additionalDistance, width: sideLength, height: sideLength))
                        } else if(j == 1){
                            gradientView = UIView(frame: CGRect(x: battersBoxViewRef.frame.width / 2.0 - additionalDistance, y: 0.0 - additionalDistance, width: sideLength, height: sideLength))
                        } else if(j == 2){
                            gradientView = UIView(frame: CGRect(x: battersBoxViewRef.frame.width / 2.0 - additionalDistance, y: battersBoxViewRef.frame.width / 2.0 - additionalDistance, width: sideLength, height: sideLength))
                        } else {
                            gradientView = UIView(frame: CGRect(x: 0.0 - additionalDistance, y: battersBoxViewRef.frame.width / 2.0 - additionalDistance, width: sideLength, height: sideLength))
                        }
                        gradientView.backgroundColor = UIColor.clear
                    }
                    
                    // Create the gradient layer using background color and new mixed color
                    let gradientLayer = CAGradientLayer()
                    DispatchQueue.main.sync {
                        gradientLayer.frame = CGRect(x: 0, y: 0, width: gradientView.frame.height, height: gradientView.frame.width)
                        gradientLayer.colors = [mixedColor.cgColor, battersBoxViewRef.backgroundColor!.cgColor]
                        gradientLayer.locations = [0.2, 1]
                    }
                    
                    // Crop the gradient layer
                    var dimenstion: CGFloat!
                    DispatchQueue.main.sync {
                        dimenstion = gradientView.frame.height
                    }
                    let aPath = UIBezierPath()
                    aPath.move(to: CGPoint(x: (dimenstion / 2.0), y: 0.0))
                    aPath.addLine(to: CGPoint(x: dimenstion, y: (dimenstion / 2.0)))
                    aPath.addLine(to: CGPoint(x: (dimenstion / 2.0), y: dimenstion))
                    aPath.addLine(to: CGPoint(x: 0.0, y: (dimenstion / 2.0)))
                    aPath.addLine(to: CGPoint(x: (dimenstion / 2.0), y: 0.0))
                    aPath.close()
                    var shapeLayer = CAShapeLayer()
                    DispatchQueue.main.sync {
                        shapeLayer.path = aPath.cgPath
                        gradientLayer.mask = shapeLayer
                    
                        // Add the layer and rotate
                        gradientView.layer.addSublayer(gradientLayer)
                        gradientView.transform = CGAffineTransform(rotationAngle: (CGFloat(-1.0) * CGFloat(M_PI_2 / 2.0)) + CGFloat(j) * CGFloat(M_PI_2))
                        battersBoxViewRef.addSubview(gradientView)
                    }
                }
            }
        }
        
        // Colored batter's box with corner gradients
        // battersBoxView
        
        
        // Iterate over each box and add gradients between neighboring boxes
        for i in 0..<battersBoxViews.count {
            for ii in 0..<battersBoxViews[i].count {
                let battersBoxViewRef = battersBoxViews[i][ii]
                
                // Iterate over the neighboring boxes
                var referenceColors = [[0, -1], [1, 0], [0, 1], [-1, 0]]
                for j in 0..<referenceColors.count{
                    // Correct edge cases
                    if(referenceColors[j][0] + ii < 0){
                        referenceColors[j][0] = 0
                    } else if (referenceColors[j][0] + ii >= battersBoxViews[i].count){
                        referenceColors[j][0] = 0
                    }
                    if(referenceColors[j][1] + i < 0){
                        referenceColors[j][1] = 0
                    } else if(referenceColors[j][1] + i >= battersBoxViews.count){
                        referenceColors[j][1] = 0
                    }
                    
                    // Bland the colors
                    var mixedColor: UIColor!
                    DispatchQueue.main.sync {
                        mixedColor = UIColor.blend(color1: battersBoxViewRef.backgroundColor!, color2: battersBoxViews[referenceColors[j][1] + i][referenceColors[j][0] + ii].backgroundColor!)
                    }
                    
                    // Create the gradient view
                    var gradientView: UIView!
                    var gradientLayer: CAGradientLayer!
                    DispatchQueue.main.sync {
                        if(j == 0){
                            gradientView = UIView(frame: CGRect(x: 0.0, y: 0.0 - (battersBoxViewRef.frame.width / 2.0), width: battersBoxViewRef.frame.width, height: battersBoxViewRef.frame.height))
                        } else if(j == 1){
                            gradientView = UIView(frame: CGRect(x: 0.0 + (battersBoxViewRef.frame.width / 2.0), y: 0.0, width: battersBoxViewRef.frame.width, height: battersBoxViewRef.frame.height))
                        } else if(j == 2){
                            gradientView = UIView(frame: CGRect(x: 0.0, y: 0.0 + (battersBoxViewRef.frame.width / 2.0), width: battersBoxViewRef.frame.width, height: battersBoxViewRef.frame.height))
                        } else {
                            gradientView = UIView(frame: CGRect(x: 0.0 - (battersBoxViewRef.frame.width / 2.0), y: 0.0, width: battersBoxViewRef.frame.width, height: battersBoxViewRef.frame.height))
                        }
                        gradientView.backgroundColor = UIColor.clear
                        
                        // Create the gradient layer using the background color and the new blended color
                        gradientLayer = CAGradientLayer()
                        gradientLayer.frame = CGRect(x: 0, y: 0, width: gradientView.frame.height, height: gradientView.frame.width)
                        gradientLayer.colors = [mixedColor.cgColor, battersBoxViewRef.backgroundColor!.cgColor]
                        gradientLayer.locations = [0.5, 1]
                    }
                    
                    // Crop the gradient layer
                    var dimenstion: CGFloat!
                    DispatchQueue.main.sync {
                        dimenstion = gradientView.frame.height
                    }
                    let aPath = UIBezierPath()
                    aPath.move(to: CGPoint(x: 0.0, y: 0.0))
                    aPath.addLine(to: CGPoint(x: dimenstion, y: 0.0))
                    aPath.addLine(to: CGPoint(x: dimenstion / 2.0, y: dimenstion))
                    aPath.addLine(to: CGPoint(x: 0.0, y: 0.0))
                    aPath.close()
                    let shapeLayer = CAShapeLayer()
                    shapeLayer.path = aPath.cgPath
                    gradientLayer.mask = shapeLayer
                    
                    // Add the layer and rotate
                    DispatchQueue.main.sync {
                        gradientView.layer.addSublayer(gradientLayer)
                        gradientView.transform = CGAffineTransform(rotationAngle: (CGFloat(M_PI_2 * Double(j))))
                        battersBoxViewRef.addSubview(gradientView)
                    }
                }
                
                
            }
        }
        
        // Colored batter's box view after compound gradients
        return UIImage(view: battersBoxView)
    }
    
}
