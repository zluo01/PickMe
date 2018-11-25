//
//  RegisterViewController.swift
//  PickMe
//
//  Created by ShaneTong on 11/25/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
  
    @IBOutlet var confirmPasswordField: UITextField!
    
    @IBOutlet var registerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        if passwordField.text != confirmPasswordField.text {
            let alertController = UIAlertController(title: "Password Mismatch", message: "Please re-enter password", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Fine", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!){(user, error) in
                if user != nil {
                    let alertController = UIAlertController(title: "Register Success!", message: "You have successfully registered!", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    print("User has signed up!")
                }
                if error != nil{
                    print("error detected!")
                    if let errorCode = AuthErrorCode(rawValue: error!._code) {
                        switch errorCode {
                        case .invalidEmail:
                            let alertController = UIAlertController(title: "Invalid Email", message: "Please enter a valid email address", preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                            break
                        case .emailAlreadyInUse:
                            let alertController = UIAlertController(title: "Email Already Existed", message: "Please use another email to register", preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                            break
                        case .weakPassword:
                            let alertController = UIAlertController(title: "Password Not Strong Enough", message: "Please provide a stronger password", preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                            break
                        default:
                            let alertController = UIAlertController(title: "Register Error", message: "Please try again", preferredStyle: .alert)
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
