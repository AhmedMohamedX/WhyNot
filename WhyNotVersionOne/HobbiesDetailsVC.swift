//
//  HobbiesDetailsVC.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 11/21/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit
import SCLAlertView
import Alamofire

class HobbiesDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var activityIndicatorView: ActivityIndicatorView!
    @IBOutlet weak var emptyImg: UIImageView!
    var hobbies : [String] = []
    var user : String?
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var titleCat: UILabel!
    @IBOutlet weak var imageV: UIImageView!
    var img : UIImage?
    var cat : String?
    var cellCol : UIColor?
    var currentUsername:String?
    let serverUrl : String = "http://"+MyUtils.ipServer+":8080/WhyNotServer"
    var loadSent : Int = 0;
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.separatorStyle = .none
        tableview.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableview.tableFooterView?.isHidden = true
        tableview.backgroundColor = UIColor.clear
        imageV.image = img
        titleCat.text = cat
        activityIndicator()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        loadFriends()
    }
    
    
    @IBAction func addHobbies(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: true)
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextField("Hobbies")
        _ = alert.addButton("Save") {
            print("Text value: \(txt.text ?? "NA")")
            if(txt.text == ""){
                let alertController = UIAlertController(title: "Why Not?", message: "Please write your hobbies", preferredStyle: .alert)
                let acceptedAction = UIAlertAction(title: "OK", style: .cancel, handler: nil )
                alertController.addAction(acceptedAction)
                self.present(alertController, animated: true, completion: {})
            } else {
                self.saveHobbiesToServer(text : txt.text!)
            }
            
        }
        _ = alert.showEdit("Why Not?", subTitle:"Set your hobbies")
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hobbies.count
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //  cat +++ currentUsername +++ hobbies[indexPath.row]
        
        let alertController = UIAlertController(title: "Why Not?", message: "Are you sure to delete your hobbies?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        })
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.deleteHobbies(hob: self.hobbies[indexPath.row])
            //self.tableView.deleteRows(at: [self.tableView.indexPath(for: cell)!], with: .fade)
        })
        alertController.addAction(deleteAction)
        
        self.present(alertController, animated: true, completion: {})
        
        
        
    }
    
    func deleteHobbies(hob : String) {
      //  http://54.154.140.247:8080/WhyNotServer/rest/hobbiesService/deletehobbies?username=houss1234&catego=SPORT&desc=HA
        startIndicator()
        let inscriptionUrl : String = serverUrl + "/rest/hobbiesService/deletehobbies?username="+currentUsername!+"&catego="+cat!+"&desc="+hob
        print("deleted url "+inscriptionUrl)
        let encodeUrl : String = inscriptionUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(encodeUrl).responseJSON { response in
            if let json = response.result.value {
                let jsonResult = json as AnyObject
                print(jsonResult)
                let deleted = jsonResult["deleted"] as! Bool
                if(deleted == true) {
                  //  ViewController.nbh = ViewController.nbh! - 1
                    MyUtils.updateHobbiesOrInvit(username: self.currentUsername!, key: "nbHobbies" , add: false)
                    print("deleted")
                    self.loadFriends()
                } else {
                    print("not deleted")
                }
            }
            self.stopIndicator()
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "cellHob")!
        let view : UIView = cell.viewWithTag(100)!
        let lab : UILabel = cell.viewWithTag(102)! as! UILabel
        lab.text = hobbies[indexPath.row] 
        view.layer.cornerRadius = 10.0
        view.backgroundColor = cellCol
        //cell.selectionStyle = UITableViewCellSelectionStyle.default
        return cell
    }
    
    func loadFriends() {
        startIndicator()
        let inscriptionUrl : String = serverUrl + "/rest/hobbiesService/getHobbiesOfCategory?username="+currentUsername!+"&categ="+cat!
        let encodeUrl : String = inscriptionUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(encodeUrl).responseJSON { response in
            if let json = response.result.value {
                self.hobbies = json as! [String]
                if(self.hobbies.count != 0) {
                    self.tableview.reloadData()
                    self.emptyImg.isHidden = true
                    self.tableview.isHidden = false
                }
                else {
                    self.emptyImg.isHidden = false
                    self.tableview.isHidden = true
                }
                
            }
            self.stopIndicator()
        }
    }
    
    func saveHobbiesToServer(text : String) {
        if text.characters.count <= 3 {
            let alert = UIAlertController(title: "Why Not?", message: "Desription should contains at least 4 characters", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            } ))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.activityIndicatorView = ActivityIndicatorView(title: "Save...", center: self.view.center)
            self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
            let inscriptionUrl : String = serverUrl + "/rest/hobbiesService/addhobbies?username="+currentUsername!+"&catego="+cat!+"&desc="+text
            let encodeUrl : String = inscriptionUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            Alamofire.request(encodeUrl).responseJSON { response in
                if let json = response.result.value {
                    let jsonResult:Dictionary = json as! Dictionary<String,AnyObject>
                    let created : Bool = (jsonResult["add"] as? Bool)!
                    if(created == true) {
                       // ViewController.nbh = ViewController.nbh! + 1
                        MyUtils.updateHobbiesOrInvit(username: self.currentUsername!, key: "nbHobbies" , add: true)
                        self.activityIndicatorView.stopAnimating()
                        print("successAdded")
                        self.loadFriends()
                    }
                } else {
                    self.activityIndicatorView.stopAnimating()
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
