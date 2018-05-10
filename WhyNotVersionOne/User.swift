//
//  User.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 11/4/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import Foundation

public class User {
    var fullName: String?
    var nbFirends: Int?
    var location : String?
    var pictureUrl : String?
    var username : String?
    
    init(fullName : String , nbFriend : Int , location : String, picUrl : String , username: String) {
        self.fullName = fullName
        self.location = location
        self.nbFirends = nbFriend
        self.pictureUrl = picUrl
        self.username = username
    }
    
    init() {
        
    }
}
