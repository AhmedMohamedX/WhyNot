//
//  ContentViewController.swift
//  SideMenuu
//
//  Created by Beyram on 11/3/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit
import Firebase

class DashboardVC: UIViewController {
    
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    var currentUser : User?
    var nbh : Int?
    var nbI : Int?
    var nbA : Int?
    @IBOutlet weak var nbActiv: UILabel!
    @IBOutlet weak var nbInvit: UILabel!
    @IBOutlet weak var nbHobbies: UILabel!
    var currentLoc : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nbActiv.text = "\(nbA!)"
        nbHobbies.text = "\(nbh!)"
        nbInvit.text = "\(nbI!)"
        
        self.title = "Home"
        if(currentUser?.pictureUrl != nil) {
            print("picture " + (currentUser?.pictureUrl)!)
            self.imgUser.sd_setImage(with: URL(string: (currentUser?.pictureUrl?.replacingOccurrences(of: "%26", with: "&").replacingOccurrences(of: "localhost", with: MyUtils.ipServer))!), placeholderImage: UIImage(named: "usericon.png"))
        }
        
        lblName.text = "Welcome " + (currentUser?.fullName)!
        lblLocation.text = "Location : " + currentLoc!
       // lblLocation.text = "Location : \((currentUser?.location)!)"
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.black.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.clipsToBounds = true
        Messaging.messaging().subscribe(toTopic: (currentUser?.username)!)
        print("Subscribed \(currentUser?.username)")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.timerForeground.invalidate()
        appDelegate.timerBackground.invalidate()
        appDelegate.timerFrom = "inApp"
        appDelegate.timerForeground = Timer.scheduledTimer(timeInterval: 1800, target: appDelegate, selector: #selector(appDelegate.checkNearbyFriends), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.16, green:0.10, blue:0.20, alpha:1.0)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = (titleDict as! [String : Any])
        navigationItem.hidesBackButton = true
    }
}
