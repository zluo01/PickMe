//
//  UserProfileViewController.swift
//  PickMe
//
//  Created by Harry Wei on 11/25/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseUI
import FirebaseDatabase
import ExpandingMenu

class UserProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, FUIAuthDelegate{

    @IBOutlet weak var myImageView: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var firstMajorLabel: UILabel!
    @IBOutlet weak var secondMajorLabel: UILabel!
    @IBOutlet weak var userActionButton: UIBarButtonItem!
    
    @IBOutlet var minorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var backFromEdit = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // first time major minor, create container
        if UserDefaults.standard.stringArray(forKey: "majorMinor") == nil{
            print(1)
            let array : [String] = ["None","None","None"]
            UserDefaults.standard.set(array, forKey: "majorMinor")
        }
        
        reloadAllData()
     
        // create following buttons
        configureExpandingMenuButton()

        // Todo display class taken or favor class table view
    }
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            userActionButton.title = "Login"
        } else { // Todo double check here
            userActionButton.title = "Log out"
        }
        if backFromEdit {
            let alertController = UIAlertController(title: "Profile Update Success", message: "You have successfully updated your profile!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            backFromEdit = false
        }
    }
    
    //Todo implement
    @IBAction func tableSwitch(_ sender: UISegmentedControl) {
        // if class taken
        // reload class taken to tableview
        
        // if favor
        //reload favor class to tableview
    }
    
    // Todo implement login logout
    @IBAction func userActions(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            // go to login page
            // identifer is ProfileToLogin
            let authUI = FUIAuth.defaultAuthUI()
            guard authUI != nil else {
                return
            }
            authUI?.delegate = self
            let authViewController = authUI!.authViewController()
            present(authViewController, animated: true, completion: nil)
        } else { // logout here
            let authUI = FUIAuth.defaultAuthUI()
            do {
                try authUI?.signOut()
                let alertController = UIAlertController(title: "Logout Success", message: "You have successfully logged out!", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                print("You have logged out!")
                reloadAllData()
                userActionButton.title = "Login"
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error != nil {
            return
        }
        //reload all data
        reloadAllData()
    }
    
    func reloadAllData() {
        print("reloadAllData")
        reloadNameAndMajor()
        reloadImage()
    }
    
    func reloadNameAndMajor() {
        print("reloadNameAndMajor")
        if Auth.auth().currentUser == nil {
            print(2)
            firstMajorLabel.text = getMajorMinor(0)
            secondMajorLabel.text = getMajorMinor(1)
            minorLabel.text = getMajorMinor(2)
            name.text = "Guest"
        }
        else {
            name.text = Auth.auth().currentUser?.displayName != nil ? Auth.auth().currentUser?.displayName! : "Anonymous"
            let ref = Database.database().reference()
            ref.observe(.value, with: {
                snapshot in
                var profile_data = (snapshot.value! as! Dictionary<String, Any>)["profile"] as! Dictionary<String, Dictionary<String, Any>>
                if profile_data.keys.contains((Auth.auth().currentUser?.uid)!) { // has profile data on database
                    if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("first") {
                        self.firstMajorLabel.text = profile_data[(Auth.auth().currentUser?.uid)!]!["firstMajor"] as? String
                    }
                    if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("second") {
                        self.secondMajorLabel.text = profile_data[(Auth.auth().currentUser?.uid)!]!["secondMajor"] as? String
                    }
                    if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("minor") {
                        self.minorLabel.text = profile_data[(Auth.auth().currentUser?.uid)!]!["minor"] as? String
                    }
                    if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("favorites") {
                        var favors = [String]()
                        for i in profile_data[(Auth.auth().currentUser?.uid)!]!["favorites"] as! [String]{
                            if (i != "DUMMY") {
                                favors.append(i)
                            }
                        }
                        UserDefaults.standard.set(favors , forKey: "fav")
                    }
                    if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("taken") {
                        var taken : [Int : [String]] = [ 1 : [], 2 : [], 3 : [], 4:[],5:[],6:[],7:[],8:[]]
                        for (semester, course) in profile_data[(Auth.auth().currentUser?.uid)!]!["taken"] as! Dictionary<String, String> {
                            let s = Int(semester[...0])!
                            taken[s]!.append(course)
                        }
                        
                        for i in 1...8 {
                            UserDefaults.standard.set(taken[i] , forKey: String(i))
                        }
                    }
                } else { // create container on the database
                    let currentUser = Auth.auth().currentUser!
                    var dict = Dictionary<String, Any>()
                    dict["first"] = "None"
                    dict["second"] = "None"
                    dict["minor"] = "None"
                    dict["favorites"] = ["DUMMY"]
                    dict["taken"] = ["10" : "DUMMY"]
                    ref.child("profile").child(currentUser.uid).setValue(dict)
                }
            })
        }
    }
    
    func reloadImage() {
        print("reloadImage")
        if Auth.auth().currentUser == nil {
            myImageView.image = UIImage(named: "user_male@3x.png")
        }
        else {
            let placeholderImage = UIImage(named: "user_male@3x.png")
            let storageRef = Storage.storage().reference()
            let uid = Auth.auth().currentUser?.uid
            let downloadRef = storageRef.child("user/\(uid!)")
            myImageView.sd_setImage(with: downloadRef, placeholderImage: placeholderImage)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func configureExpandingMenuButton() {
        let menuButtonSize: CGSize = CGSize(width: 64.0, height: 64.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), image: UIImage(named: "chooser-button-tab")!, rotatedImage: UIImage(named: "chooser-button-tab-highlighted")!)
        menuButton.center = CGPoint(x: self.view.bounds.width - 32.0, y: self.view.bounds.height - 72.0)
        self.view.addSubview(menuButton)
        
        let edit = ExpandingMenuItem(size: menuButtonSize, title: "Edit", image: UIImage(named: "heart")!, highlightedImage: UIImage(named: "heart-highlight")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            // add action here
            if Auth.auth().currentUser != nil {
                self.performSegue(withIdentifier: "profileToEdit", sender: self)
            }
            else {
                let alertController = UIAlertController(title: "User Not Logged In", message: "You have to log in before you can edit your profile!", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        menuButton.addMenuItems([edit])
        
        menuButton.willPresentMenuItems = { (menu) -> Void in
            print("MenuItems will present.")
        }
        
        menuButton.didDismissMenuItems = { (menu) -> Void in
            print("MenuItems dismissed.")
        }
    }
}
