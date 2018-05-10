//
//  FriendsCollectionVC.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 11/25/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Alamofire

class FriendsCollectionVC: UIViewController , IndicatorInfoProvider , UICollectionViewDelegate , UICollectionViewDataSource  {

    let serverUrl : String = "http://"+MyUtils.ipServer+":8080/WhyNotServer"
    var indic : String?
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var emptyImg: UIImageView!
    
    
    var itemInfo: IndicatorInfo = "View"
    var currentUsername : String?
    var currentuserPic : String?
    var recivPic : String?
    @IBOutlet weak var imgCat: UIImageView!
    var indicator = UIActivityIndicatorView()

    var listsFriends : [User] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator()
        loadFriends()
        print("viewww loaded")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listsFriends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reciev = listsFriends[indexPath.row].username
        recivPic = listsFriends[indexPath.row].pictureUrl
        performSegue(withIdentifier: "sendInvitSegue", sender: reciev)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender reciev: Any?) {
        if segue.identifier == "sendInvitSegue" {
            let destination = segue.destination as! InvitationVC
            destination.sender = currentUsername
            destination.senderPic = currentuserPic
            destination.recieverPic = recivPic
            destination.reciever = reciev as? String
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profilCell", for: indexPath)
        let imgUser : UIImageView = cell.viewWithTag(101) as! UIImageView
        let name : UILabel = cell.viewWithTag(102) as! UILabel
        if listsFriends[indexPath.row].pictureUrl == nil {
            imgUser.image = #imageLiteral(resourceName: "usericon")
        } else {
            print("url" + listsFriends[indexPath.row].pictureUrl!.replacingOccurrences(of: "%26", with: "&"))
            
            imgUser.sd_setImage(with: URL(string: listsFriends[indexPath.row].pictureUrl!.replacingOccurrences(of: "localhost", with: MyUtils.ipServer).replacingOccurrences(of: "%26", with: "&")), placeholderImage: UIImage(named: "usericon.png"))
        }

        imgUser.layer.borderWidth = 2
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor(red:0.52, green:0.07, blue:0.35, alpha:1.0).cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.clipsToBounds = true
        name.text = listsFriends[indexPath.row].fullName
        return cell
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: indic)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = (titleDict as! [String : Any])
        navigationItem.hidesBackButton = true
    }
    
    func loadFriends() {
        print("loading friends")
        startIndicator()
        let inscriptionUrl : String = serverUrl + "/rest/hobbiesService/getMatchedFriends?username="+currentUsername!+"&categ="+indic!
        let encodeUrl : String = inscriptionUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(encodeUrl).responseJSON { response in
            if let json = response.result.value {
                let jsonResult = json as! [AnyObject]
                if (jsonResult.count != 0) {
                    for i in (0..<jsonResult.count){
                        let elementResul1 = jsonResult[i]
                        let friend : User = User()
                        print(elementResul1["name"] as? String ?? "viide")
                        let name : String = elementResul1["name"] as! String
                        let username : String = elementResul1["username"] as! String
                        if let pictUrl : String = elementResul1["pictUrl"] as? String {
                            friend.pictureUrl = pictUrl.replacingOccurrences(of: "localhost", with: MyUtils.ipServer).replacingOccurrences(of: "%26", with: "&")
                        }
                        friend.fullName = name
                        friend.username = username
                        self.listsFriends.append(friend)
                    }
                    self.collectionView.reloadData()
                    self.emptyImg.isHidden = true
                    self.collectionView.isHidden = false
                } else {
                    self.emptyImg.isHidden = false
                    self.collectionView.isHidden = true
                }
                self.stopIndicator()
                
                
            }
        }
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func startIndicator() {
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.clear
        indicator.color = UIColor(red:0.16, green:0.10, blue:0.20, alpha:1.0)
    }
    
    func stopIndicator() {
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
    }
  
}
