//
//  ViewController.swift
//  SideMenuu
//
//  Created by Beyram on 11/3/17.
//  Copyright © 2017 Beyram. All rights reserved.
//

import UIKit
import SideMenu
import CoreData
import Firebase

class ViewController: UIViewController {

    var currentUser : User?
    var nbh : Int?
    var nbI : Int?
    var nbA : Int?
    fileprivate var selectedIndex = 0
    fileprivate var transitionPoint: CGPoint!
        fileprivate var navigator: UINavigationController!
    lazy fileprivate var menuAnimator : MenuTransitionAnimator! = MenuTransitionAnimator(mode: .presentation, shouldPassEventsOutsideMenu: false) { [unowned self] in
        self.dismiss(animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        switch (segue.identifier, segue.destination) {
        case (.some("presentMenu"), let menu as MenuViewController):
            menu.selectedItem = selectedIndex
            menu.delegate = self
            menu.transitioningDelegate = self
            menu.modalPresentationStyle = .custom
        case (.some("embedNavigator"), let navigator as UINavigationController):
            print("embedNavigator")
            self.navigator = navigator
            self.navigator.delegate = self
            // Pass Params From Nav Controller to DashBoard VC
            let dashboard = navigator.viewControllers.first as! DashboardVC
            dashboard.currentUser = currentUser
            dashboard.currentLoc = getCurrentLocation()
            dashboard.nbA = MyUtils.getActivitiesOrInvitation(username: (currentUser?.username)!, key: "nbActivities")
            dashboard.nbh = MyUtils.getNbHobbies(username: (currentUser?.username)!, key: "nbHobbies")
            dashboard.nbI = MyUtils.getActivitiesOrInvitation(username: (currentUser?.username)!, key: "nbInvitations")
            
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ViewController: MenuViewControllerDelegate {
    
    func menu(_: MenuViewController, didSelectItemAt index: Int, at point: CGPoint) {

        transitionPoint = point
        selectedIndex = index
        print("selected \(selectedIndex)")
        
        let dashboard = storyboard!.instantiateViewController(withIdentifier: "Dashboard") as! DashboardVC
        dashboard.currentUser = currentUser
        dashboard.nbA = MyUtils.getActivitiesOrInvitation(username: (currentUser?.username)!, key: "nbActivities")
        dashboard.nbh = MyUtils.getNbHobbies(username: (currentUser?.username)!, key: "nbHobbies")
        dashboard.currentLoc = getCurrentLocation()
        dashboard.nbI = MyUtils.getActivitiesOrInvitation(username: (currentUser?.username)!, key: "nbInvitations")
        let friends = storyboard!.instantiateViewController(withIdentifier: "Friends") as! FriendsVC
        friends.currentUser = currentUser
        let hobbies = storyboard!.instantiateViewController(withIdentifier: "Hobbies") as! HobbiesVC
        hobbies.currentUsername = currentUser?.username
        let maps = storyboard!.instantiateViewController(withIdentifier: "MapFriends") as! MapNearbyVC
        maps.currentUser = currentUser
        let invitationList = storyboard!.instantiateViewController(withIdentifier: "ListInvitations") as! ListInvitationVC
        invitationList.username = currentUser?.username
        let activitiesList = storyboard?.instantiateViewController(withIdentifier: "Activities") as! ActivitiesVC
        activitiesList.username = currentUser?.username
        activitiesList.name = currentUser?.fullName
        
        switch selectedIndex {
        case 0:
            navigator.show(dashboard, sender: nil)
        case 1:
            navigator.show(hobbies, sender: nil)
        case 2:
            navigator.show(friends, sender: nil)
        case 3:
            navigator.show(activitiesList, sender: nil)
        case 5:
            navigator.show(maps, sender: nil)
        case 4:
            navigator.show(invitationList, sender: nil)
        case 6:
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.timerForeground.invalidate()
            appDelegate.timerBackground.invalidate()
            Messaging.messaging().unsubscribe(fromTopic: (currentUser?.username)!)
            deleteCurrentUser()
            
        default:
            print("i am here")
        }
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func menuDidCancel(_: MenuViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func deleteCurrentUser()
    {
        print("deleteCurrentUser")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let coreContext = appDelegate?.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentUser"))
        do {
            try coreContext?.execute(DelAllReqVar)
            if let login = self.storyboard?.instantiateViewController(withIdentifier: "LoginC") as? LoginVC {
                print("check login Vue")
                UIApplication.shared.keyWindow?.rootViewController = login
            }
            print("deleteCurrentUser LOGOUT Success")
        }
        catch {
            print(error)
        }
    }
    
    func getCurrentLocation() -> String
    {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let coreContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CurrentUser")
        do {
            let list = try coreContext!.fetch(fetchRequest)
            return list[0].value(forKey: "location") as! String
            
            
        } catch let error as NSError {
            print(error.userInfo)
            return ""
        }
    }
}

extension ViewController: UINavigationControllerDelegate {
    
    func navigationController(_: UINavigationController, animationControllerFor _: UINavigationControllerOperation,
                              from _: UIViewController, to _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let transitionPoint = transitionPoint {
            return CircularRevealTransitionAnimator(center: transitionPoint)
        }
        return nil
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting _: UIViewController,
                             source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return menuAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MenuTransitionAnimator(mode: .dismissal)
    }
}

