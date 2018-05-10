//
//  HobbiesVC.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 11/15/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit

class HobbiesVC: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    var currentUsername:String?
    let category : [String] = [ "MUSIQUE" , "SPORT" , "TRAVEL" , "GAMING" , "READING" , "MOVIES"]
    
    let colors : [UIColor] = [ UIColor(red:0.00, green:0.90, blue:0.46, alpha:1.0) , UIColor(red:0.16, green:0.71, blue:0.96, alpha:1.0) , UIColor(red:0.85, green:0.11, blue:0.38, alpha:1.0) , UIColor(red:1.00, green:0.54, blue:0.50, alpha:1.0) , UIColor(red:1.00, green:0.84, blue:0.25, alpha:1.0) , UIColor(red:1.00, green:0.50, blue:0.67, alpha:1.0)]
    
    let imgs : [UIImage] = [#imageLiteral(resourceName: "musicC"), #imageLiteral(resourceName: "sportC"),#imageLiteral(resourceName: "travelC"),#imageLiteral(resourceName: "gameC"),#imageLiteral(resourceName: "readC"),#imageLiteral(resourceName: "movieC")]
    
    let imgsdetails : [UIImage] = [#imageLiteral(resourceName: "music-player"), #imageLiteral(resourceName: "football-2"),#imageLiteral(resourceName: "maps-and-flags"),#imageLiteral(resourceName: "game-console"),#imageLiteral(resourceName: "open-book"),#imageLiteral(resourceName: "video-player")]
    
    
    
    @IBOutlet weak var categoryTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Hobbies"
        
        categoryTableview.separatorStyle = .none
        tableview.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableview.tableFooterView?.isHidden = true
        tableview.backgroundColor = UIColor.clear
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hobbiesCell")!
        let view : UIView = cell.viewWithTag(100)!
        let label : UILabel = cell.viewWithTag(102) as! UILabel
        let img : UIImageView = cell.viewWithTag(101) as! UIImageView
        label.text = category[indexPath.row]
        view.layer.cornerRadius = 10.0
        view.backgroundColor = colors[indexPath.row]
        img.image = imgs[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell \(indexPath.row)")
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showHobbies",sender: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHobbies" {
            let hobDetails : HobbiesDetailsVC = segue.destination as! HobbiesDetailsVC
            hobDetails.cat = category[(tableview.indexPathForSelectedRow?.row)!]
            hobDetails.img = imgsdetails[(tableview.indexPathForSelectedRow?.row)!]
            hobDetails.cellCol = colors[(tableview.indexPathForSelectedRow?.row)!]
            hobDetails.currentUsername = currentUsername
            
        }
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
