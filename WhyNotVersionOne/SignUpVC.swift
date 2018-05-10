//
//  SignUpVC.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 11/9/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class SignUpVC: UIViewController , CLLocationManagerDelegate , UITextFieldDelegate   {


    @IBOutlet weak var usernameTxf: UITextField!
    @IBOutlet weak var passwordTxf: UITextField!
    @IBOutlet weak var fullnameTxf: UITextField!
    let serverUrl : String = "http://"+MyUtils.ipServer+":8080/WhyNotServer"
    var locationManager:CLLocationManager!
    var lat : Double?
    var lng : Double?
        var activityIndicatorView: ActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorView = ActivityIndicatorView(title: "Sign Up...", center: self.view.center)
        self.usernameTxf.delegate = self
        self.passwordTxf.delegate = self
        self.fullnameTxf.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        determineMyCurrentLocation()
    }
    
    @IBAction func goLoginView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createAccount(_ sender: Any) {
        
        let name : String = fullnameTxf.text!
        let username : String = usernameTxf.text!
        let password : String = passwordTxf.text!
        
        if (username.characters.count >= 6 ) {
            
            if (password.characters.count >= 6) {
                
                if(name.characters.count >= 6 ) {
                    self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
                    self.activityIndicatorView.startAnimating()
                    let inscriptionUrl : String = serverUrl + "/rest/userService/inscription?name="+name+"&password="+password+"&username="+username+"&lat=\(lat!)&lng=\(lng!)"
                    let encodeUrl : String = inscriptionUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                    print("MyEncodeUrl \(encodeUrl)")
                    // print(inscriptionUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
                    Alamofire.request(encodeUrl).responseJSON { response in
                        print("Request: \(String(describing: response.request))")   // original url request
                        print("Response: \(String(describing: response.response))") // http url response
                        print("Result: \(response.result)")                         // response serialization result
                        
                        if let json = response.result.value {
                            self.activityIndicatorView.stopAnimating()
                            print("JSON: \(json)") // serialized json response
                            let jsonResult:Dictionary = json as! Dictionary<String,AnyObject>
                            let created : Bool = (jsonResult["created"] as? Bool)!
                            if(created == false) {
                                let alert = UIAlertController(title: "Why Not?", message: "Failed to sign up ! User already exist.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                let alert = UIAlertController(title: "Why Not?", message: "Subscription has succeeded ! ", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    
                } else {
                    let alertController = UIAlertController(title: "Why Not?", message: "FullName must contain at least 6 letter ", preferredStyle: .alert)
                    let acceptedAction = UIAlertAction(title: "OK", style: .cancel, handler: nil )
                    alertController.addAction(acceptedAction)
                    self.present(alertController, animated: true, completion: {})
                }
                
                
            } else {
                let alertController = UIAlertController(title: "Why Not?", message: "Password must contain at least 6 letter ", preferredStyle: .alert)
                let acceptedAction = UIAlertAction(title: "OK", style: .cancel, handler: nil )
                alertController.addAction(acceptedAction)
                self.present(alertController, animated: true, completion: {})
            }
            
        } else {
            
            let alertController = UIAlertController(title: "Why Not?", message: "Username must contain at least 6 letter ", preferredStyle: .alert)
            let acceptedAction = UIAlertAction(title: "OK", style: .cancel, handler: nil )
            alertController.addAction(acceptedAction)
            self.present(alertController, animated: true, completion: {})
        }        

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
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        lat = Double(userLocation.coordinate.latitude)
        lng = Double(userLocation.coordinate.longitude)
        locationManager.stopUpdatingLocation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.usernameTxf.resignFirstResponder()
        self.passwordTxf.resignFirstResponder()
        self.fullnameTxf.resignFirstResponder()
        return true
    }

}
