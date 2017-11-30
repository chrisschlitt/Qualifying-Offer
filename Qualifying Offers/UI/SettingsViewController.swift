//
//  SettingsViewController.swift
//  Qualifying Offers
//
//  Created by Christopher Schlitt on 11/29/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import UIKit
import WebKit
import Down

class SettingsViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var updateSalariesButton: UIButton!
    @IBOutlet weak var acknowledgementsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // UI Changes
        self.headerView.layer.borderColor = UIColor.lightGray.cgColor
        self.headerView.layer.borderWidth = 1.5
        self.updateSalariesButton.clipsToBounds = true
        self.updateSalariesButton.layer.cornerRadius = 3.0
        
        let down = Down(markdownString: generateAcknowledgements())
        let attributedString = try! down.toAttributedString()
        let mutableString = NSMutableAttributedString(attributedString: attributedString)
        mutableString.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.darkGray], range: NSMakeRange(0, mutableString.length))
        
        self.acknowledgementsLabel.attributedText = mutableString
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateSalariesButtonPressed(_ sender: Any) {
        print("Updating Salaries")
        self.performSegue(withIdentifier: "Go to Load", sender: self)
    }
    
    // Generate the acknowldgements string
    private func generateAcknowledgements() -> String {
        return "# Acknowledgements \n## Data Sources \n**Player ID Index** _http://legacy.baseballprospectus.com/sortable/playerids/playerid_list.csv_ \nAn index mapping player name to various identifiers \n \n**Baseball Data API Reference** _https://github.com/baseballhackday/data-and-resources/wiki/Resources-and-ideas_ \nA directory of APIs for accessing baseball information \n \n**MLB Player Headshots API** _http://gdx.mlb.com/images/gameday/mugshots/mlb/545361@4x.jpg_ \nMaps player ID to player image \n \n**MLB Salary Information** _https://questionnaire-148920.appspot.com/swe/_ \nSalary information given by MLB Analytics \n \n## Open Source Frameworks \n**Swift Soup** _https://github.com/scinfu/SwiftSoup_ \nSwiftSoup is a pure Swift library, cross-platform(macOS, iOS, tvOS, watchOS and Linux!), for working with real-world HTML. It provides a very convenient API for extracting and manipulating data, using the best of DOM, CSS, and jquery-like methods. SwiftSoup implements the WHATWG HTML5 specification, and parses HTML to the same DOM as modern browsers do. \n \n**NVActivityIndicatorView** _https://github.com/ninjaprox/NVActivityIndicatorView_ \nNVActivityIndicatorView is a collection of awesome loading animations. \nThis is original a fork from DGActivityIndicatorView, inspired by Loaders.css, written in Swift with full implementation of animations, plus more. \n \n**Down** _https://github.com/iwasrobbed/Down_ \nBlazing fast Markdown rendering in Swift, built upon cmark. \n \n**PopupDialog** _https://github.com/Orderella/PopupDialog_ \nPopup Dialog is a simple, customizable popup dialog written in Swift. \n \n## Stack-Overflow Answers \n_Formatting_ \n\n**Filtering digits out of a string** _https://stackoverflow.com/questions/29971505/filter-non-digits-from-string_ \n\n**Formatting a number for currency** _https://stackoverflow.com/questions/31021197/how-to-add-commas-to-a-number-in-swift_ \n \n_User Interface_ \n\n**Expanding a UICollectionViewCell on tap** _https://stackoverflow.com/questions/38115217/expanding-uicollectionview-and-its-cell-when-tapped_ \n\n**Status bar background color** _https://stackoverflow.com/questions/39802420/change-status-bar-background-color-in-swift-3_ \n\n**Convert UIView to UIImage** _https://stackoverflow.com/questions/30696307/how-to-convert-a-uiview-to-an-image_ \n\n**Making an NSAttributedString** _https://stackoverflow.com/questions/24666515/how-do-i-make-an-attributed-string-using-swift_ \n "
    }
    
    // Handle Reload completion
    @IBAction func unwindFromLoadViewController( _ sender: UIStoryboardSegue) {
        for viewController in (self.tabBarController as! TabViewController).viewControllers! {
            print(viewController)
            if viewController is RankViewController {
                viewController.viewDidLoad()
            }
        }
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "Go to Load"){
            let loadViewController = segue.destination as! LoadViewController
            loadViewController.isInitialLoad = false
        }
    }
    

}
