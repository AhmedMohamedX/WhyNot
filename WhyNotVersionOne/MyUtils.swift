//
//  MyUtils.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 1/9/18.
//  Copyright © 2018 Beyram. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class MyUtils {
    
    static let ipServer = "54.154.140.247"
    
    
    static func updateHobbiesOrInvit(username : String , key : String , add : Bool) {
        var newNb : Int = 0
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "CurrentUser")
        let predicate = NSPredicate(format: "username = '\(username)'")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let coreContext = appDelegate?.persistentContainer.viewContext
        
        fetchRequest.predicate = predicate
        do
        {
            let test = try coreContext?.fetch(fetchRequest)
            if test?.count == 1
            {
                let objectUpdate = test![0] as! NSManagedObject
                let nb : Int = objectUpdate.value(forKey: key) as! Int
                if add == true {
                    newNb = nb+1
                } else {
                    newNb = nb - 1
                }
                objectUpdate.setValue(newNb, forKey: key)
                do{
                    try coreContext?.save()
                    print("Update")
                }
                catch
                {
                    print(error)
                }
            }
        }
        catch
        {
            print(error)
        }
    }
    
    static func getNbHobbies(username : String , key : String) -> Int{
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "CurrentUser")
        let predicate = NSPredicate(format: "username = '\(username)'")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let coreContext = appDelegate?.persistentContainer.viewContext
        
        fetchRequest.predicate = predicate
        do
        {
            let test = try coreContext?.fetch(fetchRequest)
            if test?.count == 1
            {
                let objectUpdate = test![0] as! NSManagedObject
                let nb : Int = objectUpdate.value(forKey: key) as! Int
                return nb
            }
        }
        catch
        {
            print(error)
        }
        return 0
    }
    
    static func updateActivitiesOrInvitation(username : String , key : String , newNb : Int) {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "CurrentUser")
        let predicate = NSPredicate(format: "username = '\(username)'")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let coreContext = appDelegate?.persistentContainer.viewContext
        
        fetchRequest.predicate = predicate
        do
        {
            let test = try coreContext?.fetch(fetchRequest)
            if test?.count == 1
            {
                let objectUpdate = test![0] as! NSManagedObject
                objectUpdate.setValue(newNb, forKey: key)
                do{
                    try coreContext?.save()
                    print("Update")
                }
                catch
                {
                    print(error)
                }
            }
        }
        catch
        {
            print(error)
        }
    }
    
    static func getActivitiesOrInvitation(username : String , key : String) -> Int{
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "CurrentUser")
        let predicate = NSPredicate(format: "username = '\(username)'")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let coreContext = appDelegate?.persistentContainer.viewContext
        
        fetchRequest.predicate = predicate
        do
        {
            let test = try coreContext?.fetch(fetchRequest)
            if test?.count == 1
            {
                let objectUpdate = test![0] as! NSManagedObject
                let nb : Int = objectUpdate.value(forKey: key) as! Int
                return nb
            }
        }
        catch
        {
            print(error)
        }
        return 0
    }
    
}
