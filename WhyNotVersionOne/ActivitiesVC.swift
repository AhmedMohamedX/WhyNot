//
//  ActivitiesVC.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 12/12/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit
import FacebookCore
import FBSDKShareKit
import Alamofire
import SDWebImage
import Photos

class ActivitiesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var tableview: UITableView!
    let serverUrl : String = "http://"+MyUtils.ipServer+":8080/WhyNotServer"
    var activitiesList : [Proposition] = []
    var username : String?
    var name : String?
    let picker = UIImagePickerController()
    var idPropSelected : Int?
    var indicator = UIActivityIndicatorView()

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ActivitiesVC.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor(red:0.16, green:0.10, blue:0.20, alpha:1.0)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.separatorStyle = .none
        tableview.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableview.tableFooterView?.isHidden = true
        tableview.backgroundColor = UIColor.clear
        picker.delegate = self
        activityIndicator()
        loadActivities()
        self.tableview.addSubview(self.refreshControl)

    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        loadActivities()
        refreshControl.endRefreshing()
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activitiesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell")!
        let prop : Proposition = activitiesList[indexPath.row]
        let activImage : UIImageView = cell.viewWithTag(101) as! UIImageView
        let userImage : UIImageView = cell.viewWithTag(102) as! UIImageView
        let nom : UILabel = cell.viewWithTag(103) as! UILabel
        let view : UIView = cell.viewWithTag(200)!
        let date : UILabel = cell.viewWithTag(104) as! UILabel
        let btnShare : UIButton = cell.viewWithTag(105) as! UIButton
        let btnPicker : UIButton = cell.viewWithTag(106) as! UIButton
        btnShare.accessibilityLanguage = "\(indexPath.row)"
        btnPicker.accessibilityLanguage = "\(indexPath.row)"
        if(prop.urlActivity == nil) {
            activImage.image = #imageLiteral(resourceName: "notfound")
        } else {
            activImage.sd_setImage(with: URL(string: prop.urlActivity!.replacingOccurrences(of: "localhost", with: MyUtils.ipServer).replacingOccurrences(of: "%26", with: "&")), placeholderImage: UIImage(named: "notfound.png"))
        }
        if(name == prop.sender) {
            nom.text = prop.reciever
            
            
            if prop.recieverPic != nil {
                userImage.sd_setImage(with: URL(string: prop.recieverPic!.replacingOccurrences(of: "%26", with: "&").replacingOccurrences(of: "localhost", with: MyUtils.ipServer)), placeholderImage: UIImage(named: "usericon.png"))
               // print(prop.reciever! + " " + prop.recieverPic!)
            } else {
                userImage.image = #imageLiteral(resourceName: "usericon")
            }
           /* userImage.sd_setImage(with: URL(string: prop.recieverPic!.replacingOccurrences(of: "%26", with: "&")), placeholderImage: UIImage(named: "usericon.png"))*/
            //loadingPic(urlPic: prop.recieverPic!, img: userImage)
        } else {
            nom.text = prop.sender
            if prop.userPic != nil {
                userImage.sd_setImage(with: URL(string: prop.userPic!.replacingOccurrences(of: "%26", with: "&").replacingOccurrences(of: "localhost", with: MyUtils.ipServer)), placeholderImage: UIImage(named: "usericon.png"))
               // print(prop.sender! + " " + prop.userPic!)
            } else {
                userImage.image = #imageLiteral(resourceName: "usericon")
            }
            
           // loadingPic(urlPic: prop.userPic!, img: userImage)
        }
        userImage.layer.borderWidth = 1
        userImage.layer.masksToBounds = false
        userImage.layer.borderColor = UIColor.black.cgColor
        userImage.layer.cornerRadius = userImage.frame.height/2
        userImage.clipsToBounds = true
        date.text = getFormatDate(dateS: prop.date!)
        view.layer.cornerRadius = 10
        btnShare.addTarget(self, action: #selector(shareFB(sender:)), for: .touchUpInside)
        btnPicker.addTarget(self, action: #selector(takePic(sender:)), for: .touchUpInside)
        return cell
    }
    
    func shareFB(sender: UIButton) {
        let id = Int(sender.accessibilityLanguage!)
        let selectedIndex = IndexPath(row: id!, section: 0)
        let prop : Proposition = activitiesList[selectedIndex.row]
        //print("selected Cell \(selectedIndex.row)" )
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        if(prop.urlActivity != nil) {
            content.contentURL = NSURL(string: prop.urlActivity!.replacingOccurrences(of: "localhost", with: MyUtils.ipServer)) as URL!
        }
        content.quote = "@\(prop.sender!) and @\(prop.reciever!) share some great moments in \(prop.placename!)"
        FBSDKShareDialog.show(from: self, with: content, delegate: nil)
    }
    
    func takePic(sender: UIButton) {
        let id = Int(sender.accessibilityLanguage!)
        let selectedIndex = IndexPath(row: id!, section: 0)
        let prop : Proposition = activitiesList[selectedIndex.row]
        idPropSelected = prop.id
        print("selected Cell \(selectedIndex.row)  idPropSelected \(idPropSelected)" )
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = (titleDict as! [String : Any])
        navigationItem.hidesBackButton = true
        startIndicator()
    }
    
    func loadActivities() {
        //activitiesList = []
        //self.tableview.reloadData()
        print("loadAct")
        let inscriptionUrl : String = serverUrl + "/rest/propositionService/getActivities?idUser=\(username!)"
        let encodeUrl : String = inscriptionUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(encodeUrl).responseJSON { response in
            if let json = response.result.value {
                let jsonResult = json as! [AnyObject]
                MyUtils.updateActivitiesOrInvitation(username: self.username!, key: "nbActivities", newNb: jsonResult.count)
                if (jsonResult.count != 0) {
                    self.activitiesList.removeAll()
                    for i in (0..<jsonResult.count){
                        //ViewController.nbA = jsonResult.count
                        let elem = jsonResult[i]
                        let prop : Proposition = Proposition()
                        prop.placename = elem["placename"] as? String
                        prop.time = elem["time"] as? String
                        prop.date = elem["date"] as? String
                        prop.id = elem["idProposition"] as? Int
                        
                        let recievers = elem["recievers"] as! [AnyObject]
                        let rec = recievers[0] as! Dictionary<String,AnyObject>
                        prop.reciever = rec["name"] as? String
                        prop.recieverPic = rec["pictUrl"] as? String
                        
                        let from = elem["from"] as! Dictionary<String,AnyObject>
                        prop.sender = from["name"] as? String
                        prop.userPic = from["pictUrl"] as? String
                        
                        let medias = elem["medias"] as! [AnyObject]
                        if(medias.count>0) {
                            let med = medias[medias.count-1] as? Dictionary<String,AnyObject>
                            prop.urlActivity = med?["urlFile"] as? String
                        }
                        self.activitiesList.append(prop)
                    }
                    self.tableview.reloadData()
                    
                    self.emptyImg.isHidden = true
                    self.tableview.isHidden = false
                } else {
                    //MyUtils.updateUserStats(username: self.username!, key: "nbActivities" , add: false)
                    self.emptyImg.isHidden = false
                    self.tableview.isHidden = true
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageName: String = getFileName(info: info)
        
        uploadImage(img: chosenImage , imgName : imageName)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(img : UIImage , imgName : String) {
        let imgData = UIImageJPEGRepresentation(img, 0.2)!
        startIndicator()
        let parameters = ["idProp": "\(idPropSelected!)"]
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "img",fileName: imgName, mimeType: "multipart/form-data")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
        },
                         to:serverUrl + "/rest/propositionService/uploadImage")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    self.loadActivities()
                    print(response.result.value ?? "nil Resp")
                }
                
            case .failure(let encodingError):
                print(encodingError)
                self.stopIndicator()
            }
        }
    }
    
    func getFileName(info: [String : Any]) -> String {
        
        if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {
            let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
            let asset = result.firstObject
            let fileName = asset?.value(forKey: "filename")
            let fileUrl = URL(string: fileName as! String)
            if let name = fileUrl?.deletingPathExtension().lastPathComponent {
                print(name)
                return name
            }
        }
        return ""
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
