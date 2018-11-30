//
//  UserProfileViewController.swift
//  PickMe
//
//  Created by Harry Wei on 11/25/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import ExpandingMenu

class UserProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var myImageView: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var firstMajorLabel: UILabel!
    @IBOutlet weak var secondMajorLabel: UILabel!
    @IBOutlet weak var userActionButton: UIBarButtonItem!
    
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
        
        if isGuest() {
            userActionButton.title = "Login"
        } else { // Todo double check here
            userActionButton.title = "Logout"
        }
        configureExpandingMenuButton()
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
        if isGuest() {
            // go to login page
            // identifer is ProfileToLogin
        } else { // logout here
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                let alertController = UIAlertController(title: "Logout Success", message: "You have successfully logged out!", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                print("You have logged out!")
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
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
