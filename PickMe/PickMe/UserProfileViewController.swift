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

class UserProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var myImageView: UIImageView!
    
    @IBOutlet weak var nameTextView: UITextView!

    @IBOutlet weak var majorTextView: UITextView!

    @IBOutlet weak var minorTextView: UITextView!
    
    @IBAction func importImage(_ sender: UIButton) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = true
        self.present(image, animated: true){
            //After it is complete
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            myImageView.image = image
        }
        else{
            //Error message
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextView.text = "Jon Halom"
        nameTextView.font = UIFont.boldSystemFont(ofSize: 22)
        nameTextView.isEditable = true
        nameTextView.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        
        majorTextView.text = "Computer Science"
        majorTextView.font = UIFont(name: "Verdana", size: 17)
        majorTextView.isEditable = true
        majorTextView.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        
        minorTextView.text = "French"
        minorTextView.font = UIFont(name: "Verdana", size: 17)
        minorTextView.isEditable = true
        minorTextView.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logout(_ sender: Any) {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
