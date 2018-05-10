//
//  AppDelegate.swift
//  WhyNotVersionOne
//
//  Created by Beyram on 11/2/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import UserNotifications
import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var NScurrentUser : NSManagedObject?
    var NScurrentLocation : NSManagedObject?
    var isConnected : Bool = false
    var isLocated : Bool = false
    var nbh : Int?
    var nbI : Int?
    var nbA : Int?
    var lat : Double?
    var long : Double?
    var timerBackground = Timer()
    var timerForeground = Timer()
    var timerFrom : String?
    let serverUrl : String = "http://"+MyUtils.ipServer+":8080/WhyNotServer"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        UIApplication.shared.isStatusBarHidden = false
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor(red:0.16, green:0.10, blue:0.20, alpha:1.0)
        FirebaseApp.configure()
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        isConnected = checkCurrentUser()
        isLocated = checkCurrentLocation()
        if(isConnected == true) {
            let currentUser = User()
            print("user already connected")
            currentUser.fullName = NScurrentUser?.value(forKey: "fullname") as! String?
            currentUser.location = NScurrentUser?.value(forKey: "location") as! String?
            currentUser.pictureUrl = NScurrentUser?.value(forKey: "pictureUrl") as! String?
            currentUser.username = NScurrentUser?.value(forKey: "username") as! String?
            currentUser.nbFirends = NScurrentUser?.value(forKey: "nbFriends") as! Int?
            nbI = NScurrentUser?.value(forKey: "nbInvitations") as! Int?
            nbA = NScurrentUser?.value(forKey: "nbActivities") as! Int?
            nbh = NScurrentUser?.value(forKey: "nbHobbies") as! Int?
            // Override point for customization after application launch.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: ViewController = storyboard.instantiateViewController(withIdentifier: "ViewC") as! ViewController
            viewController.currentUser = currentUser
            viewController.nbh = nbh
            viewController.nbA = nbA
            viewController.nbI = nbI
            window?.rootViewController = viewController
        } else {
            print("user is not connected")
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    

    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        print("Recieved")
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        print("Recieved")
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        if isConnected == true {
            print("isConnected == true")
            if isLocated == true {
                print("isLocated == true")
                timerForeground.invalidate()
                timerFrom = "Background"
                timerBackground = Timer.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(self.checkNearbyFriends), userInfo: nil, repeats: true)
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if isConnected == true {
            if isLocated == true {
                timerFrom = "Foreground"
                timerBackground.invalidate()
                timerForeground = Timer.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(self.checkNearbyFriends), userInfo: nil, repeats: true)
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        timerBackground.invalidate()
        timerForeground.invalidate()
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "WhyNotVersionOne")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    func checkCurrentUser() -> Bool {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let coreContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CurrentUser")
        do {
            let list = try coreContext!.fetch(fetchRequest)
            if (list.count == 0) {
                print("list user is empty")
                return false
            } else {
                NScurrentUser = list[0]
                if(NScurrentUser == nil) {
                    return false
                } else {
                    return true
                }
            }
            
            
        } catch let error as NSError {
            print(error.userInfo)
            return false
        }
    }
    
    func checkCurrentLocation() -> Bool {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let coreContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CurrentLocation")
        do {
            let list = try coreContext!.fetch(fetchRequest)
            if (list.count == 0) {
                print("list current location is empty")
                return false
            } else {
                print("list current location not empty")
                NScurrentLocation = list[0]
                if(NScurrentLocation == nil) {
                    return false
                } else {
                    return true
                }
            }
            
            
        } catch let error as NSError {
            print(error.userInfo)
            return false
        }
    }
    
    func checkNearbyFriends() {
        let username = NScurrentUser?.value(forKey: "username") as? String
        lat = NScurrentLocation?.value(forKey: "latitude") as? Double
        long = NScurrentLocation?.value(forKey: "longitude") as? Double
        print("checkNearbyFriends USERNAME \(username!) from " + timerFrom!)
        print("checkNearbyFriends Latitude \(lat!)")
        print("checkNearbyFriends Longititude \(long!)")
        
        let url = URL(string : serverUrl + "/rest/userService/getNearbyFriends?lat=\(lat!)&lng=\(long!)&username=\(username!)" )
        Alamofire.request(url!, method: .get).responseJSON {
            response in
            if(response.result.isSuccess) {
                print("Success")
                if let JSON = response.result.value {
                    let jsonResult:Dictionary = JSON as! Dictionary<String,AnyObject>
                    print(jsonResult)
                }
            } else if (response.result.isFailure) {
                print("Failure")
            }
        }
    }
}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Present Notif")
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
           
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
         completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Present Notif")
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

