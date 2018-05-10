//
//  InvitationVC.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 11/28/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit
import Alamofire
import SearchTextField
import CoreLocation


class InvitationVC: UIViewController , CLLocationManagerDelegate ,UITextFieldDelegate , UITextViewDelegate {

    @IBOutlet weak var imgReciever: UIImageView!
    @IBOutlet weak var imgSender: UIImageView!
    @IBOutlet weak var subject: UITextView!
    @IBOutlet weak var placename: SearchTextField!
    var places : [String] = []
    
    @IBOutlet weak var pickTxv: UITextField!
    @IBOutlet weak var timeTxv: UITextField!
    let serverUrl : String = "http://"+MyUtils.ipServer+":8080/WhyNotServer/rest/propositionService/addProposition?"
    var datePicker : UIDatePicker!
    var sender: String?
    var reciever: String?
    var senderPic: String?
    var recieverPic: String?
    var locationManager:CLLocationManager!
    var lat : Double?
    var lng : Double?
    var activityIndicatorView: ActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(sender! + "  " + reciever!)
        if recieverPic != nil {
            self.imgReciever.sd_setImage(with: URL(string: recieverPic!.replacingOccurrences(of: "%26", with: "&").replacingOccurrences(of: "localhost", with: MyUtils.ipServer)), placeholderImage: UIImage(named: "usericon.png"))
        }
        if senderPic != nil {
            self.imgSender.sd_setImage(with: URL(string: senderPic!.replacingOccurrences(of: "%26", with: "&").replacingOccurrences(of: "localhost", with: MyUtils.ipServer)), placeholderImage: UIImage(named: "usericon.png"))
        }
        
        imgSender.layer.borderWidth = 1
        imgSender.layer.masksToBounds = false
        imgSender.layer.borderColor = UIColor.black.cgColor
        imgSender.layer.cornerRadius = imgSender.frame.height/2
        imgSender.clipsToBounds = true
        
        imgReciever.layer.borderWidth = 1
        imgReciever.layer.masksToBounds = false
        imgReciever.layer.borderColor = UIColor.black.cgColor
        imgReciever.layer.cornerRadius = imgReciever.frame.height/2
        imgReciever.clipsToBounds = true
        
        
        subject.delegate = self
        placename.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineMyCurrentLocation()
    }
    
    @IBAction func cancelInvitation(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickUpDate(self.pickTxv)
    }
    
    
    @IBAction func timeBeginEditing(_ sender: Any) {
        self.pickUpTime(self.timeTxv)
    }

    func pickUpDate(_ textField : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.date
        textField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(InvitationVC.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(InvitationVC.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    func pickUpTime(_ textField : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.time
        textField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(InvitationVC.doneTimeClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(InvitationVC.cancelTimeClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd"
        pickTxv.text = dateFormatter1.string(from: datePicker.date)
        pickTxv.resignFirstResponder()
    }
    func cancelClick() {
        timeTxv.resignFirstResponder()
    }
    
    func doneTimeClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "HH:mm"
        timeTxv.text = dateFormatter1.string(from: datePicker.date)
        timeTxv.resignFirstResponder()
    }
    
    func cancelTimeClick() {
        timeTxv.resignFirstResponder()
    }
    
    
    @IBAction func sendInvitation(_ sender: Any) {
        
        let sub : String = subject.text
        let place : String = placename.text!
        //let send = sender as! String
        let firstparams : String = "from="+self.sender!+"&reciever="+self.reciever!
        let secondparams : String = "&placename="+place+"&subject="+sub
        let thirdparams : String = "&date="+pickTxv.text!+"&time="+timeTxv.text!
        let saveInvitUrl : String = serverUrl + firstparams + secondparams + thirdparams
        
        if sub != "" {
            if place != "" {
                if pickTxv.text != "" {
                    if timeTxv.text != "" {
                        self.activityIndicatorView = ActivityIndicatorView(title: "Sending...", center: self.view.center)
                        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
                        print(saveInvitUrl)
                        let encodeUrl : String = saveInvitUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                        Alamofire.request(encodeUrl).responseJSON { response in
                            if let json = response.result.value {
                                print("JSON: \(json)") // serialized json response
                                let jsonResult:Dictionary = json as! Dictionary<String,AnyObject>
                                let logged : Bool = (jsonResult["add"] as? Bool)!
                                if(logged == true) {
                                    self.activityIndicatorView.stopAnimating()
                                    let alert = UIAlertController(title: "Why Not?", message: "Invitation was sent successfully", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in
                                        self.dismiss(animated: true, completion: nil)
                                    } ))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            } else {
                                self.activityIndicatorView.stopAnimating()
                                let alert = UIAlertController(title: "Why Not?", message: "Failed to send ivitation !", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    } else {
                        let alert = UIAlertController(title: "Why Not?", message: "Time cannot be empty.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "Why Not?", message: "Date cannot be empty.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Why Not?", message: "Place cannot be empty.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Why Not?", message: "Subject cannot be empty.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

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
        print("Lat \(lat)  \(lng)")
        
        loadPlaces(lat: lat!, lng: lng!)
        locationManager.stopUpdatingLocation()
    }
    
    func loadPlaces (lat : Double , lng : Double) {
        let url = URL(string : "https://api.foursquare.com/v2/venues/search?client_id=UC42MAF02BPC5OCN01ZSTONW44HH1SZWWSYHHAKSGZRU0FCN&client_secret=VXT5BVGOHFHSFPNTIA1YFVNX5TD4A5KOF5XB3EG2UEDVUIZY&ll=\(lat),\(lng)&intent=checkin&v=20171202&radius=100000&limit=50")
        Alamofire.request(url!, method: .get).responseJSON {
            response in
            if(response.result.isSuccess) {
                print("Success")
                if let JSON = response.result.value {
                    let jsonResult:Dictionary = JSON as! Dictionary<String,AnyObject>
                    let response:Dictionary = jsonResult["response"] as! Dictionary<String,AnyObject>
                    let venues:[AnyObject] = response["venues"] as! [AnyObject]
                    for i in (0..<venues.count)
                    {
                        let vn:Dictionary = venues[i] as! Dictionary<String,AnyObject>
                        let name : String = vn["name"]! as! String
                        self.places.append(name)
                    }
                    self.placename.filterStrings(self.places)
                    print("\(self.places.count)")
                    //self.placename.maxResultsListHeight = 10
                    
                }
            } else if (response.result.isFailure) {
                print("Failure")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.subject.resignFirstResponder()
        self.placename.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            subject.resignFirstResponder()
        }
        return true
    }

    
}
