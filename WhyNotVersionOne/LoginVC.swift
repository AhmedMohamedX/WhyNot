//
//  ViewController.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 11/2/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import CoreLocation
import CoreData

class LoginVC: UIViewController , CLLocationManagerDelegate ,UITextFieldDelegate {
    
    var dict:Dictionary <String,AnyObject> = [:]
    var activityIndicatorView: ActivityIndicatorView!
    let serverUrl : String = "http://"+MyUtils.ipServer+":8080/WhyNotServer"
    var nbh : Int?
    var nbI : Int?
    var nbA : Int?
    @IBOutlet weak var usernameTxv: UITextField!
    @IBOutlet weak var passwordTxv: UITextField!
    var cityName : String = ""
    var lat : Double?
    var lng : Double?
    
    let currentUser = User()
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorView = ActivityIndicatorView(title: "Connecting...", center: self.view.center)
        self.usernameTxv.delegate = self
        self.passwordTxv.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        determineMyCurrentLocation()
    }

    @IBAction func loginToFacebook(_ sender: Any) {
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email","user_friends"], from: self) { (result, error) in
            if (error == nil){
                if( result?.isCancelled == true) {
                    print("canceled")
                    self.activityIndicatorView.stopAnimating()
                    return
                }
                //
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        if((FBSDKAccessToken.current()) != nil){
                            print("token " + fbloginresult.token.tokenString)
                            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,name, picture.type(large),friends"])
                                .start(completionHandler: { (connection, result, error) -> Void in
                                if (error == nil){
                                    self.dict = result as! [String : AnyObject]
                                    //print(result!)
                                    print(self.dict)
                                    let name : String = self.dict["name"] as! String
                                    let idFacebook : String = self.dict["id"] as! String
                                    let picJson = self.dict["picture"]?["data"]! as! [String : AnyObject]
                                    let pic : String = picJson["url"] as! String
                                    print(pic)
                                    let friendSummaryJson = self.dict["friends"]?["summary"] as! [String : AnyObject]
                                    let friendNb : Int = friendSummaryJson["total_count"] as! Int
                                    self.currentUser.pictureUrl = pic.replacingOccurrences(of: "localhost", with: MyUtils.ipServer).replacingOccurrences(of: "%26", with: "&")
                                    self.saveFacebookUser(id : idFacebook , name : name , picUrl: pic )
                                    self.currentUser.nbFirends = friendNb
                                    //self.performSegue(withIdentifier: "loginSuccess", sender: currentUser)
                                    
                                }
                            })
                        }
                    }
                }
            }
        }
        
    }
    
    
    @IBAction func loginToServer(_ sender: Any) {
        print("hello")
        let username : String = usernameTxv.text!
        let password : String = passwordTxv.text!
        
        if username != "" {
            if password != "" {
                print("\(password) lmmlk")
                self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.startAnimating()
                
                let inscriptionUrl : String = serverUrl + "/rest/userService/signIn?password="+password+"&username="+username+"&lat=\(lat!)&lng=\(lng!)"
                print(inscriptionUrl)
                let encodeUrl : String = inscriptionUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                Alamofire.request(encodeUrl).responseJSON { response in
                    if let json = response.result.value {
                        print("JSON: \(json)") // serialized json response
                        let jsonResult:Dictionary = json as! Dictionary<String,AnyObject>
                        
                        let logged : Bool = (jsonResult["logged"] as? Bool)!
                        if(logged == false) {
                            self.activityIndicatorView.stopAnimating()
                            let alert = UIAlertController(title: "Why Not?", message: "Failed to sign in ! User does not exist.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            print(jsonResult)
                            let cUser : Dictionary = jsonResult["current_user"] as! Dictionary<String,AnyObject>
                            let name = cUser["name"] as! String
                            let picUrl = cUser["pictUrl"] as? String
                            let username = cUser["username"] as? String
                            print(name)
                            self.nbh = (jsonResult["nbHobbies"] as? Int)!
                            self.nbI = (jsonResult["nbInvitation"] as? Int)!
                            self.nbA = (jsonResult["nbActivity"] as? Int)!
                            print("analytics \(self.nbA)  \(self.nbh)  \(self.nbI)")
                            self.saveUserinCoreData(fullName: name, username: username!, nbHob: self.nbh!, nbAct: self.nbA!, nbInvi: self.nbI!, loc: self.cityName, picUrl: picUrl!, nbFriend: 0)

                            self.currentUser.fullName = name
                            self.currentUser.pictureUrl = picUrl?.replacingOccurrences(of: "localhost", with: MyUtils.ipServer).replacingOccurrences(of: "%26", with: "&")
                            self.currentUser.username = username
                            self.performSegue(withIdentifier: "loginSuccess", sender: self.currentUser)
                            
                            self.activityIndicatorView.stopAnimating()
                        }
                    }
                }
            } else {
                let alertController = UIAlertController(title: "Why Not?", message: "Please write your password", preferredStyle: .alert)
                let acceptedAction = UIAlertAction(title: "OK", style: .cancel, handler: nil )
                alertController.addAction(acceptedAction)
                self.present(alertController, animated: true, completion: {})
            }

        } else {
            let alertController = UIAlertController(title: "Why Not?", message: "Please write your username", preferredStyle: .alert)
            let acceptedAction = UIAlertAction(title: "OK", style: .cancel, handler: nil )
            alertController.addAction(acceptedAction)
            self.present(alertController, animated: true, completion: {})

        }
        


    }
    
    func saveFacebookUser(id : String , name : String , picUrl: String ) {
        let inscriptionUrl : String = serverUrl + "/rest/userService/inscriptionfb?username="+id+"&pictUrl=" + picUrl.replacingOccurrences(of: "&", with: "%26")+"&lat=\(lat!)&lng=\(lng!)&name=" + name 
        let encodeUrl : String = inscriptionUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(encodeUrl).responseJSON { response in
            if let json = response.result.value {
                let jsonResult:Dictionary = json as! Dictionary<String,AnyObject>
                let cUser : Dictionary = jsonResult["current_user"] as! Dictionary<String,AnyObject>
                let name = cUser["name"] as! String
                let picUrl = cUser["pictUrl"] as! String
                let username = cUser["username"] as! String
                print(jsonResult)
               // print(picUrl)
                self.nbh = (jsonResult["nbHobbies"] as? Int)!
                self.nbI = (jsonResult["nbInvitation"] as? Int)!
                self.nbA = (jsonResult["nbActivity"] as? Int)!
                print("analytics \(self.nbA)  \(self.nbh)  \(self.nbI)")
                self.saveUserinCoreData(fullName: name, username: username, nbHob: self.nbh!, nbAct: self.nbA!, nbInvi: self.nbI!, loc: self.cityName, picUrl: picUrl, nbFriend: 0)
                self.currentUser.username = username
                self.currentUser.fullName = name
                self.currentUser.pictureUrl = picUrl.replacingOccurrences(of: "localhost", with: MyUtils.ipServer).replacingOccurrences(of: "%26", with: "&")
                self.activityIndicatorView.stopAnimating()
                self.performSegue(withIdentifier: "loginSuccess", sender: self.currentUser)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue : " + segue.identifier! )
        if(segue.identifier == "loginSuccess") {
            if let destination = segue.destination as? ViewController {
                destination.currentUser = sender as? User
                destination.nbA = nbA
                destination.nbh = nbh
                destination.nbI = nbI
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("disappear")
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        lat = Double(userLocation.coordinate.latitude)
        lng = Double(userLocation.coordinate.longitude)
        if lat != nil && lng != nil {
            saveLocation(longitude: lng!, latitude: lat!, id: 1)
        }
        locationManager.stopUpdatingLocation()
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userLocation, completionHandler: { placemarks, error in
            guard let addressDict = placemarks?[0].addressDictionary else {
                return
            }
            self.cityName = " "
            if let city = addressDict["City"] as? String {
                self.cityName = self.cityName + city + ","
            }
            if let country = addressDict["Country"] as? String {
                self.cityName = self.cityName + country
                self.currentUser.location = self.cityName
                print(self.cityName)
            }
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.passwordTxv.resignFirstResponder()
        self.usernameTxv.resignFirstResponder()
        return true
    }
    
    func saveUserinCoreData(fullName : String , username : String , nbHob : Int , nbAct : Int , nbInvi : Int , loc : String , picUrl : String , nbFriend : Int) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let coreContext = appDelegate?.persistentContainer.viewContext
        let itemEntityDescription = NSEntityDescription.entity(forEntityName: "CurrentUser", in: coreContext!)
        let item = NSManagedObject(entity: itemEntityDescription!, insertInto: coreContext)
        item.setValue(fullName , forKey: "fullname")
        item.setValue(loc , forKey: "location")
        item.setValue(picUrl , forKey: "pictureUrl")
        item.setValue(username , forKey: "username")
        item.setValue(nbAct , forKey: "nbActivities")
        item.setValue(nbFriend , forKey: "nbFriends")
        item.setValue(nbHob , forKey: "nbHobbies")
        item.setValue(nbInvi , forKey: "nbInvitations")
        
        do {
            try coreContext?.save()
            print("Current User saved")
            
        } catch let error as NSError {
            print(error.userInfo)
        }
    }
    
    func saveLocation(longitude : Double , latitude : Double , id : Int ) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let coreContext = appDelegate?.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentLocation"))
        do {
            try coreContext?.execute(DelAllReqVar)
            print("Empty Location")
            let itemEntityDescription = NSEntityDescription.entity(forEntityName: "CurrentLocation", in: coreContext!)
            let item = NSManagedObject(entity: itemEntityDescription!, insertInto: coreContext)
            item.setValue(latitude , forKey: "latitude")
            item.setValue(longitude , forKey: "longitude")
            item.setValue(id , forKey: "id")
            do {
                try coreContext?.save()
                print("Current Location saved")
            } catch let error as NSError {
                print(error.userInfo)
            }
        }
        catch {
            print(error)
        }
    }
    

    

    
}

