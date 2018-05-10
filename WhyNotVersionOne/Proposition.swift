//
//  Proposition.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 12/12/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import Foundation

public class Proposition {
    
    var id : Int?
    var  sender : String?
    var  reciever : String?
    var  date : String?
    var  subject : String?
    var  placename : String?
    var  time : String?
    var  userPic : String?
    var  urlActivity : String?
    var  recieverPic : String?
    
    init(id : Int, sender : String , reciever : String , date : String, subject : String , placename: String , time : String , userPic : String, urlActivity : String , recieverPic: String ) {
        self.sender = sender
        self.reciever = reciever
        self.date = date
        self.subject = subject
        self.placename = placename
        self.time = time
        self.userPic = userPic
        self.urlActivity = urlActivity
        self.recieverPic = recieverPic
        self.id = id
    }
    
    init() {
    
    }
    
}
