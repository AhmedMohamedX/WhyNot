//
//  FriendsVC.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 11/7/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class FriendsVC:  TwitterPagerTabStripViewController {
    var isReload = false
    var currentUser : User?
    
    override func viewDidLoad() {
        settings.style.titleColor = UIColor.white
        self.settings.style.dotColor = UIColor(red:0.35, green:0.86, blue:0.00, alpha:1.0)
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let mainV1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsFriends") as! FriendsCollectionVC
        let mainV2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsFriends") as! FriendsCollectionVC
        let mainV3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsFriends") as! FriendsCollectionVC
        let mainV4 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsFriends") as! FriendsCollectionVC
        let mainV5 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsFriends") as! FriendsCollectionVC
        let mainV6 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsFriends") as! FriendsCollectionVC
        mainV1.indic = "SPORT"
        mainV2.indic = "GAMING"
        mainV3.indic = "TRAVEL"
        mainV4.indic = "READING"
        mainV5.indic = "MOVIES"
        mainV6.indic = "MUSIQUE"
        mainV1.currentUsername = currentUser?.username
        mainV2.currentUsername = currentUser?.username
        mainV3.currentUsername = currentUser?.username
        mainV4.currentUsername = currentUser?.username
        mainV5.currentUsername = currentUser?.username
        mainV6.currentUsername = currentUser?.username
        mainV1.currentuserPic = currentUser?.pictureUrl
        mainV2.currentuserPic = currentUser?.pictureUrl
        mainV3.currentuserPic = currentUser?.pictureUrl
        mainV4.currentuserPic = currentUser?.pictureUrl
        mainV5.currentuserPic = currentUser?.pictureUrl
        mainV6.currentuserPic = currentUser?.pictureUrl
        return [mainV1, mainV2,mainV3, mainV4,mainV5, mainV6]
    
    }
    
    @IBAction func reloadTapped(_ sender: AnyObject) {
        isReload = true
        reloadPagerTabStripView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = (titleDict as! [String : Any])
        navigationItem.hidesBackButton = true
    }
    
}

