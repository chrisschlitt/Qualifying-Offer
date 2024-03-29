//
//  TabViewController.swift
//  Qualifying Offers
//
//  Created by Christopher Schlitt on 11/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    var salaries: [PlayerSalary] = [PlayerSalary]()
    var qualifyingOffer: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Go to first tab
        self.selectedIndex = 0
        // Scroll to top of collection view
        for viewController in (self.viewControllers)! {
            if let rankViewController = viewController as? RankViewController {
                rankViewController.playerCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
            }
        }
        super.viewDidAppear(animated)
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
