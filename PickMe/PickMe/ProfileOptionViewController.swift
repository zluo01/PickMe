//
//  ProfileOptionViewController.swift
//  PickMe
//
//  Created by ShaneTong on 11/25/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileOptionViewController: UIViewController {

    @IBOutlet var registerButton: UIButton!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // save personal information to local
    // Todo fix, empty string can also login
    @IBAction func loginAction(_ sender: UIButton) {
        print(self.emailField.text!)
        print(self.passwordField.text!)
        Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!){(user, error) in
            if user != nil {
                let alertController = UIAlertController(title: "Login Successful!", message: "You have successfully logged in!", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                print("User has signed up!")
                self.performSegue(withIdentifier: "LoginToProfileSegue", sender: nil)
                
            }
            if error != nil{
                print("error detected!")
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                    case .wrongPassword:
                        let alertController = UIAlertController(title: "Wrong Password", message: "Please enter the correct password", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                        break
                    case .userNotFound:
                        let alertController = UIAlertController(title: "Email Not Found", message: "Make sure you have already registered", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                        break
                    case .invalidEmail:
                        let alertController = UIAlertController(title: "Invalid Email", message: "Please enter a valid email address", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                        break
                    default:
                        let alertController = UIAlertController(title: "Login Error", message: "Oops", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                        break
                    }
                }
            }
        }
    }
}
