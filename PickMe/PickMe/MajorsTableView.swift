//
//  MajorsTableView.swift
//  PickMe
//
//  Created by Alan zhang on 2018/11/23.
//  Copyright © 2018 z.luo. All rights reserved.
//

// This table view aims to display the majors.

import UIKit
import FirebaseDatabase
class MajorsTableView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var majorsTable: UITableView!

    var majors = Dictionary<String, Dictionary<String, Dictionary<String, String>>>()
    var majorSeletced : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        majorsTable.dataSource = self
        majorsTable.delegate = self
        
        // fetch data
        fetchDataFromFirebase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return majors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myCell = tableView.dequeueReusableCell(withIdentifier: "theCell")
        
        if myCell == nil {
            myCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "theCell")
        }
        
        myCell?.textLabel!.text = Array(majors.keys).sorted()[indexPath.row]
        
        return myCell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        majorSeletced = Array(majors.keys).sorted()[indexPath.row]
        self.performSegue(withIdentifier: "MajorToCourses", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! CoursesTableView
        destination.major = majorSeletced
        destination.courses = majors[majorSeletced]!
    }
    
    func fetchDataFromFirebase(){
        let ref = Database.database().reference()
        
        ref.observe(.value, with: {
            snapshot in
            let courses = (snapshot.value! as! Dictionary<String, Any>)["classes"] as! Dictionary<String, Dictionary<String, String>>
            for c in courses {
                let m = c.key.split(separator: " ")[0].uppercased()
                if self.majors.keys.contains(m) { // if major is added
                    self.majors[m]![c.key.uppercased()] = c.value
                } else {
                    self.majors[m] = Dictionary<String, Dictionary<String, String>>()
                    self.majors[m]![c.key.uppercased()] = c.value
                }
            }
            self.majorsTable.reloadData()
        })
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
