//
//  ListInvitationVC.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 12/6/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit
import SwipyCell
import Alamofire
import Foundation

class ListInvitationVC: UIViewController , UITableViewDelegate , UITableViewDataSource, SwipyCellDelegate {

    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var username : String?
    let serverUrl : String = "http://"+MyUtils.ipServer+":8080/WhyNotServer"
    var invitationList : [Proposition] = []
    var loadSent : Int = 0;
    
    @IBOutlet weak var labType: UILabel!
    @IBOutlet weak var switchI: UISwitch!
    var indicator = UIActivityIndicatorView()

    @IBAction func switchInvit(_ sender: Any) {
        let state : Bool = switchI.isOn
        if state == true {
            labType.text = "Recieved"
            loadInvit()
        } else {
            labType.text = "Sent"
            loadSentInvit()
        }
    }
    
    var numberItems : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberItems = invitationList.count
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.tableFooterView?.isHidden = true
        tableView.backgroundColor = UIColor.clear
        activityIndicator()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("loading \(self.loadSent))")
        let prop : Proposition = invitationList[indexPath.row]
        print ("date " + prop.date!)
        let dateTime = getFormatDate(dateS: prop.date!)
        print("heeh" + dateTime)
        if(loadSent == 0) {
            print("recieved")
            let cell = tableView.dequeueReusableCell(withIdentifier: "invitCell") as! SwipyCell
            let checkView = viewWithImageName("check")
            let greenColor = UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
            let crossView = viewWithImageName("cross")
            let redColor = UIColor(red: 232.0 / 255.0, green: 61.0 / 255.0, blue: 14.0 / 255.0, alpha: 1.0)
            cell.addSwipeTrigger(forState: .state(0, .left), withMode: .toggle, swipeView: checkView, swipeColor: greenColor, completion: { cell, trigger, state, mode in
                print("Did swipe \"Checkmark\" cell Mixed 1")
                print("id \(prop.id)")
                self.acceptInvit(id: prop.id!)

            })
            cell.addSwipeTrigger(forState: .state(1, .left), withMode: .exit, swipeView: crossView, swipeColor: redColor, completion: { cell, trigger, state, mode in
                let alertController = UIAlertController(title: "Why Not?", message: "Are you sure you want to refuse the invitation?", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    cell.swipeToOrigin {
                        print("Swiped back")
                    }
                })
                alertController.addAction(cancelAction)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    self.refuseInvit(id: prop.id!)
                    //self.tableView.deleteRows(at: [self.tableView.indexPath(for: cell)!], with: .fade)
                })
                alertController.addAction(deleteAction)
                
                self.present(alertController, animated: true, completion: {})
                
                //  self.deleteCell(cell)
            })
            let img : UIImageView = cell.viewWithTag(101) as! UIImageView
            img.layer.borderWidth = 1
            img.layer.masksToBounds = false
            img.layer.borderColor = UIColor.black.cgColor
            img.layer.cornerRadius = img.frame.height/2
            img.clipsToBounds = true
            let name : UILabel = cell.viewWithTag(102) as! UILabel
            let date : UILabel = cell.viewWithTag(103) as! UILabel
            let subject : UILabel = cell.viewWithTag(104) as! UILabel
            let placeName : UILabel = cell.viewWithTag(105) as! UILabel
            if prop.userPic != nil {
                img.sd_setImage(with: URL(string: prop.userPic!.replacingOccurrences(of: "%26", with: "&").replacingOccurrences(of: "%26", with: "&")), placeholderImage: UIImage(named: "usericon"))
            } else {
                img.image = #imageLiteral(resourceName: "usericon")
            }
            name.text = prop.sender
            subject.text = prop.subject
          //  print("proop \(prop.date!)")
            
           // print("TimeFormatted" + getFormatDate(dateS: prop.date!) + " " + prop.time!)
            date.text = getFormatDate(dateS: prop.date!) + " " + prop.time!
            placeName.text = prop.placename
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sentCell")!
            let img : UIImageView = cell.viewWithTag(101) as! UIImageView
            
            img.layer.borderWidth = 1
            img.layer.masksToBounds = false
            img.layer.borderColor = UIColor.black.cgColor
            img.layer.cornerRadius = img.frame.height/2
            img.clipsToBounds = true
            
            let name : UILabel = cell.viewWithTag(102) as! UILabel
            let date : UILabel = cell.viewWithTag(103) as! UILabel
            let subject : UILabel = cell.viewWithTag(104) as! UILabel
            let placeName : UILabel = cell.viewWithTag(105) as! UILabel
            
            if prop.userPic != nil {
                img.sd_setImage(with: URL(string: prop.userPic!.replacingOccurrences(of: "%26", with: "&").replacingOccurrences(of: "%26", with: "&")), placeholderImage: UIImage(named: "usericon"))
            } else {
                img.image = #imageLiteral(resourceName: "usericon")
            }
            name.text = prop.sender
            subject.text = prop.subject
            date.text = getFormatDate(dateS: prop.date!) + " " + prop.time!
            placeName.text = prop.placename
            return cell
        }
    }

    func viewWithImageName(_ imageName: String) -> UIView {
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        return imageView
    }
    
    func swipyCellDidStartSwiping(_ cell: SwipyCell) {
        
    }
    
    // When the user ends swiping the cell this method is called
    func swipyCellDidFinishSwiping(_ cell: SwipyCell, atState state: SwipyCellState, triggerActivated activated: Bool) {
        print("swipe finished - activated: \(activated), state: \(state)")
    }
    
    // When the user is dragging, this method is called with the percentage from the border
    func swipyCell(_ cell: SwipyCell, didSwipeWithPercentage percentage: CGFloat, currentState state: SwipyCellState, triggerActivated activated: Bool) {
        print("swipe - percentage: \(percentage), activated: \(activated), state: \(state)")
    }
    
    func deleteCell(_ cell: SwipyCell) {
        numberItems -= 1
        
        let indexPath = tableView.indexPath(for: cell)
        tableView.deleteRows(at: [indexPath!], with: .fade)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = (titleDict as! [String : Any])
        navigationItem.hidesBackButton = true
        loadInvit()
    }
    
    
    func loadInvit() {
        startIndicator()
        loadSent = 0
        invitationList.removeAll()
        let inscriptionUrl : String = serverUrl + "/rest/propositionService/getRecivedProposition?reciever=\(username!)"
        let encodeUrl : String = inscriptionUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(encodeUrl).responseJSON { response in
            if let json = response.result.value {
                let jsonResult = json as! [AnyObject]
                MyUtils.updateActivitiesOrInvitation(username: self.username!, key: "nbInvitations", newNb: jsonResult.count)
                if (jsonResult.count != 0) {
                    //ViewController.nbI = jsonResult.count
                    for i in (0..<jsonResult.count){
                        let elem = jsonResult[i]
                        let prop : Proposition = Proposition()
                        prop.placename = elem["placename"] as? String
                        prop.time = (elem["time"] as! String)
                        prop.date = (elem["date"] as! String)
                        prop.id = elem["idProposition"] as? Int
                        let from = elem["from"] as! Dictionary<String,AnyObject>
                        prop.sender = from["name"] as? String
                        prop.userPic = (from["pictUrl"] as? String)?.replacingOccurrences(of: "localhost", with: MyUtils.ipServer).replacingOccurrences(of: "%26", with: "&")
                        prop.subject = elem["subject"] as? String
                        self.invitationList.append(prop)
                    }
                    self.numberItems = self.invitationList.count
                    print("recieved \(self.loadSent))")
                    self.tableView.reloadData()
                    self.emptyImg.isHidden = true
                    self.tableView.isHidden = false
                } else {
                    self.numberItems = self.invitationList.count
                    print("recieved \(self.loadSent))")
                    self.tableView.reloadData()
                    self.emptyImg.isHidden = false
                    self.tableView.isHidden = true
                }
                self.stopIndicator()
            }
        }
    }
    
    func loadSentInvit() {
        loadSent = 1
        invitationList.removeAll()
        startIndicator()
       // print(username! + "is")
       // print("loadInvit")
        let inscriptionUrl : String = serverUrl + "/rest/propositionService/getSentProposition?from=\(username!)"
       // print(inscriptionUrl)
        let encodeUrl : String = inscriptionUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(encodeUrl).responseJSON { response in
            if let json = response.result.value {
                let jsonResult = json as! [AnyObject]
               // print(jsonResult)
                if (jsonResult.count != 0) {
                    for i in (0..<jsonResult.count){
                        let elem = jsonResult[i]
                        let prop : Proposition = Proposition()
                        prop.placename = elem["placename"] as? String
                        prop.time = (elem["time"] as! String)
                        prop.date = (elem["date"] as! String)
                        prop.id = elem["id"] as? Int
                        let recievers = elem["recievers"] as! [AnyObject]
                        let rec = recievers[0] as! Dictionary<String,AnyObject>
                        prop.sender = rec["name"] as? String
                        prop.userPic = (rec["pictUrl"] as? String)?.replacingOccurrences(of: "localhost", with: MyUtils.ipServer).replacingOccurrences(of: "%26", with: "&")
                        prop.subject = elem["subject"] as? String
                        self.invitationList.append(prop)
                    }
                    
                    self.numberItems = self.invitationList.count
                    self.tableView.reloadData()
                    print("sent \(self.loadSent))")
                    
                     self.emptyImg.isHidden = true
                     self.tableView.isHidden = false
                } else {
                    self.numberItems = self.invitationList.count
                    print("recieved \(self.loadSent))")
                    self.tableView.reloadData()
                    self.emptyImg.isHidden = false
                    self.tableView.isHidden = true
                }
                self.stopIndicator()
            }
        }
    }
    
    func getFormatDate(dateS : String) -> String {
        /*
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm:ss a"
        dateFormatter.timeZone =  NSTimeZone(name: "UTC") as TimeZone!
        let date = dateFormatter.date(from: dateS)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeStamp = dateFormatter.string(from: date!)
        return timeStamp*/
        let index = dateS.index(dateS.startIndex, offsetBy: 12)
        return dateS.substring(to: index)
    }
    
    func acceptInvit(id :Int) {
        let inscriptionUrl : String = serverUrl + "/rest/propositionService/acceptProposition?idInvit=\(id)"
        let encodeUrl : String = inscriptionUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(encodeUrl).responseJSON { response in
            if let json = response.result.value {
                print(json)
                let resp = json as! Dictionary<String,AnyObject>
                let rs = resp["add"] as! Bool
                if(rs == true) {
                    MyUtils.updateHobbiesOrInvit(username: self.username!, key: "nbInvitations", add: false)
                    self.numberItems -= 1
                    //ViewController.nbI = ViewController.nbI! - 1
                    self.tableView.reloadData()
                    let alertController = UIAlertController(title: "Why Not?", message: "Invitation was accepted", preferredStyle: .alert)
                    let acceptedAction = UIAlertAction(title: "OK", style: .cancel, handler: nil )
                    alertController.addAction(acceptedAction)
                    self.present(alertController, animated: true, completion: {})
                    self.loadInvit()
                }
            }
        }
    }
    
    func refuseInvit(id :Int) {
        let inscriptionUrl : String = serverUrl + "/rest/propositionService/refuseProposition?idInvit=\(id)"
        let encodeUrl : String = inscriptionUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(encodeUrl).responseJSON { response in
            if let json = response.result.value {
                print(json)
                let resp = json as! Dictionary<String,AnyObject>
                let rs = resp["add"] as! Bool
                if(rs == true) {
                    //ViewController.nbI = ViewController.nbI! - 1
                    MyUtils.updateHobbiesOrInvit(username: self.username!, key: "nbInvitations", add: false)
                    self.numberItems -= 1
                    self.tableView.reloadData()
                    let alertController = UIAlertController(title: "Why Not?", message: "Invitation was refused", preferredStyle: .alert)
                    let acceptedAction = UIAlertAction(title: "OK", style: .cancel, handler: nil )
                    alertController.addAction(acceptedAction)
                    self.present(alertController, animated: true, completion: {})
                    self.loadInvit()
                }
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
