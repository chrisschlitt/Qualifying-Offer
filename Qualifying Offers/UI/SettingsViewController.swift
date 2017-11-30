//
//  SettingsViewController.swift
//  Qualifying Offers
//
//  Created by Christopher Schlitt on 11/29/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var updateSalariesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.headerView.layer.borderColor = UIColor.lightGray.cgColor
        self.headerView.layer.borderWidth = 1.5
        
        self.updateSalariesButton.clipsToBounds = true
        self.updateSalariesButton.layer.cornerRadius = 3.0
        
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
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
