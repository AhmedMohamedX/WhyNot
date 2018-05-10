//
//  LocationUtils.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 11/14/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import Foundation
import CoreLocation


public class LocationUtils {
    
    
    func getAdressName(loc : CLLocationCoordinate2D) -> String {
        var cityName = ""
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            guard let addressDict = placemarks?[0].addressDictionary else {
                return
            }
            if let city = addressDict["City"] as? String {
                cityName = cityName + city + ","
                print(city)
            }
            if let country = addressDict["Country"] as? String {
                cityName = cityName + country
                print(country)
            }
        })
        print("city" + cityName)
        return cityName
    }
    
}
