//
//  MainViewController.swift
//  PickMe
//
//  Created by Harry Wei on 11/25/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MainViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func register(_ sender: Any){
        Auth.auth().createUser(withEmail: self.email.text!, password: self.passwod.text!){(user, error) in
            if user != nil {
                print("User has signed up!")
            }
            if error != nil{
                print("error detected!")
            }
        }
        
    }
    @IBAction func signin(_ sender: Any){
        Auth.auth().signIn(withEmail: self.email.text!, password: self.passwod.text!){(user, error) in
            if user != nil {
                print("User has signed In!")
            }
            if error != nil{
                print("error detected!")
            }
        }
    }
    


}
