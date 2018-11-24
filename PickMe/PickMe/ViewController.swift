//
//  ViewController.swift
//  PickMe
//
//  Created by 凡 on 11/18/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var group = Dictionary<String, Dictionary<String, Dictionary<String, String>>>()
    
    func fetchDataFromFirebase(){
        let ref = Database.database().reference()
        
        ref.observe(.value, with: {
            snapshot in
            let courses = (snapshot.value! as! Dictionary<String, Any>)["classes"] as! Dictionary<String, Dictionary<String, String>>
            for c in courses {
                let m = c.key.split(separator: " ")[0].uppercased()
                if self.group.keys.contains(m) { // if major is added
                    self.group[m]![c.key.uppercased()] = c.value
                } else {
                    self.group[m] = Dictionary<String, Dictionary<String, String>>()
                    self.group[m]![c.key.uppercased()] = c.value
                }
            }
            
        })
    }
}

