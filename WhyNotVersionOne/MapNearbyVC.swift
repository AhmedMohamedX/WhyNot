//
//  MapNearbyVC.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 11/28/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire

class MapNearbyVC: UIViewController ,CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapFriend: MKMapView!
    var locationManager = CLLocationManager()
    let serverUrl : String = "http://"+MyUtils.ipServer+":8080/WhyNotServer"
    var lat : Double?
    var lng : Double?
    var currentUser : User?
    var userLocation:CLLocation?
    let annotationIdentifier : String = "666"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WhyNot Map"
        mapFriend.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeNastyMapMemory() {
        mapFriend.delegate = nil
        mapFriend.removeFromSuperview()
        mapFriend = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       // removeNastyMapMemory()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineMyCurrentLocation()
        loadFriends()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.16, green:0.10, blue:0.20, alpha:1.0)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = (titleDict as! [String : Any])
        navigationItem.hidesBackButton = true
        
    }
    
    
    func showFriendPosition(Lat:Double,Long:Double,user:AnyObject) {
        if(Lat != lat && Long != lng) {
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Lat, Long)
            let annotation = MKPointAnnotation()
            annotation.accessibilityHint = "beyram"
            let name = user["name"] as! String
            annotation.coordinate = location
            annotation.title = name
            annotation.accessibilityValue = user["username"] as? String
            let distance : Int = Int(userDistance(from: annotation)!) / 1000
            annotation.subtitle = "Distance : \(distance) KM"
            mapFriend.addAnnotation(annotation)
        }
    }
    
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation?.coordinate.latitude)")
        print("user longitude = \(userLocation?.coordinate.longitude)")
        lat = Double((userLocation?.coordinate.latitude)!)
        lng = Double((userLocation?.coordinate.longitude)!)
        mapFriend.showsUserLocation = true
        let coordinates = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
        let circle : MKCircle = MKCircle(center: coordinates, radius: 50000)
        self.mapFriend.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)), animated: true)
        self.mapFriend.add(circle)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    
    func loadFriends() {
        let locationUrl : String = serverUrl + "/rest/userService/getAllLocalisationOfUser"
        Alamofire.request(locationUrl).responseJSON { response in
            if let JSON = response.result.value {
                let jsonResult:Dictionary = JSON as! Dictionary<String,AnyObject>
                let jsonLocation = jsonResult ["locations"] as! [AnyObject]
                for j in (0..<jsonLocation.count){
                    let elementResul = jsonLocation[j]
                    let latitude : Double = elementResul["latitude"] as! Double
                    let longitude: Double = elementResul["longitude"] as! Double
                    let  id:NSNumber  = elementResul["idLocation"]as! NSNumber
                    let getUserUrl :String = self.serverUrl + "/rest/userService/getByIdLocation?idLocation="+id.stringValue
                    print(getUserUrl)
                    Alamofire.request(getUserUrl).responseJSON { response in
                        if let JSONUSER = response.result.value {
                            let jsonUserResult1:Dictionary = JSONUSER as! Dictionary<String,AnyObject>
                            let cUser  = jsonUserResult1["user"] as! [AnyObject]
                            
                            for i in (0..<cUser.count){
                                let elementResul1 = cUser[i]
                                print(cUser)
                                print(id)
                                self.showFriendPosition(Lat: latitude,Long: longitude,user:elementResul1 as AnyObject)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor(red:0.16, green:0.10, blue:0.20, alpha:1.0).withAlphaComponent(0.3)
        renderer.strokeColor = UIColor(red:0.16, green:0.10, blue:0.20, alpha:1.0)
        renderer.lineWidth = 1
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapFriend.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        if view == nil {
            if annotation.coordinate.latitude != mapFriend.userLocation.coordinate.latitude && annotation.coordinate.longitude != mapFriend.userLocation.coordinate.longitude {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                view?.canShowCallout = true
                view?.rightCalloutAccessoryView = UIButton(type: .contactAdd)                
            }
        } else {
            view?.annotation = annotation
        }

        let pinImage = #imageLiteral(resourceName: "usericon")
        let size = CGSize(width: pinImage.size.width / 2, height: pinImage.size.height / 2)

        view?.image = resizeImageWith(newSize: size, img: pinImage)
     //   print("subtitle " + (annotation.accessibilityHint ?? "hh")!)
        let image = #imageLiteral(resourceName: "usericon")
        
        let leftCalloutImageView = UIImageView(image: resizeImageWith(newSize: size, img: image))
        leftCalloutImageView.layer.cornerRadius = 14 //number of your choice
        leftCalloutImageView.layer.masksToBounds = true
        leftCalloutImageView.tintColor = .white
        view?.leftCalloutAccessoryView = leftCalloutImageView
        return view
    }
    
    func resizeImageWith(newSize: CGSize , img : UIImage) -> UIImage {
        
        let horizontalRatio = newSize.width / img.size.width
        let verticalRatio = newSize.height / img.size.height
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: img.size.width * ratio, height: img.size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        img.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    var selectedAnnotation: MKPointAnnotation!
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            selectedAnnotation = view.annotation as? MKPointAnnotation
            print(selectedAnnotation.title!)
            print(selectedAnnotation.accessibilityValue ?? "current")
            performSegue(withIdentifier: "sendInvitSegue", sender: self)
        }
    }
    
    private func userDistance(from point: MKPointAnnotation) -> Double? {
        let pointLocation = CLLocation(
            latitude:  point.coordinate.latitude,
            longitude: point.coordinate.longitude
        )
        return userLocation?.distance(from: pointLocation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendInvitSegue" {
            let invitationVC : InvitationVC = segue.destination as! InvitationVC
            invitationVC.reciever = selectedAnnotation.accessibilityValue
            invitationVC.sender = currentUser?.username
        }
    }
    
}
