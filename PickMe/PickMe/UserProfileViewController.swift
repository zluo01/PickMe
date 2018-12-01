//
//  UserProfileViewController.swift
//  PickMe
//
//  Created by Harry Wei on 11/25/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
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
    
    //    @IBAction func importImage(_ sender: UIButton) {
//        let image = UIImagePickerController()
//        image.delegate = self
//        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        image.allowsEditing = true
//        self.present(image, animated: true){
//            //After it is complete
//        }
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
//            myImageView.image = image
//        }
//        else{
//            //Error message
//        }
//        self.dismiss(animated: true, completion: nil)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        configureExpandingMenuButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            userActionButton.title = "Login"
        } else { // Todo double check here
            userActionButton.title = "Logout"
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
        if Auth.auth().currentUser == nil {
            firstMajorLabel.text = "Major / Minor"
            secondMajorLabel.text = "Major / Minor"
            minorLabel.text = "Major / Minor"
            name.text = "Guest"
        }
        else {
            name.text = Auth.auth().currentUser?.displayName != nil ? Auth.auth().currentUser?.displayName! : "Anonymous"
            var user_data = Dictionary<String, Dictionary<String, String>>()
            let ref = Database.database().reference()
            ref.observe(.value, with: {
                snapshot in
                user_data = (snapshot.value! as! Dictionary<String, Any>)["profile"] as! Dictionary<String, Dictionary<String, String>>
            })
            if user_data.keys.contains((Auth.auth().currentUser?.uid)!) {
                if user_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("first_major") {
                    firstMajorLabel.text = user_data[(Auth.auth().currentUser?.uid)!]!["first_major"]
                }
                if user_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("second_major") {
                    secondMajorLabel.text = user_data[(Auth.auth().currentUser?.uid)!]!["second_major"]
                }
                if user_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("minor") {
                    minorLabel.text = user_data[(Auth.auth().currentUser?.uid)!]!["minor"]
                }
            }
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
            self.performSegue(withIdentifier: "profileToEdit", sender: self)
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
