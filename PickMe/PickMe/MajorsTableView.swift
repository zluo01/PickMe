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
import SwiftyPlistManager

class MajorsTableView: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var majorsTable: UITableView!
    @IBOutlet weak var majorSearch: UISearchBar!
    
    var majors = Dictionary<String, Dictionary<String, Dictionary<String, String>>>()
    var majorSeletced : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        majorsTable.dataSource = self
        majorsTable.register(UITableViewCell.self, forCellReuseIdentifier: "theCell")
        majorsTable.delegate = self
        majorSearch.delegate = self
        
        // fetch data
        fetchDataFromFirebase("")
        
        // defualt as guest, first time user update local data
        if UserDefaults.standard.stringArray(forKey: "login") == nil{
            let array : [String] = ["false"]
            UserDefaults.standard.set(array, forKey: "login")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange: String) {
        self.fetchDataFromFirebase(textDidChange.uppercased())
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return majors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myCell = tableView.dequeueReusableCell(withIdentifier: "theCell")
        
        if myCell == nil {
            myCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "theCell")
        }
        if indexPath.row%2 == 0 {
            myCell?.backgroundColor = UIColor(red: 230/255, green: 244/255, blue: 242/255, alpha: 0.5)
        }
        else {
            myCell?.backgroundColor = UIColor(red: 230/255, green: 244/255, blue: 242/255, alpha: 0)
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
        destination.courses = majors[majorSeletced]!
    }
    
    func fetchDataFromFirebase(_ keywords: String){
        let ref = Database.database().reference()
        self.majors.removeAll()
        
        ref.observe(.value, with: {
            snapshot in
            let courses = (snapshot.value! as! Dictionary<String, Any>)["classes"] as! Dictionary<String, Dictionary<String, String>>
            for c in courses {
                let m = c.key.split(separator: " ")[0].uppercased()
                if keywords.isEmpty || m.contains(keywords) {
                    if self.majors.keys.contains(m) { // if major is added
                        self.majors[m]![c.key.uppercased()] = c.value
                    } else {
                        self.majors[m] = Dictionary<String, Dictionary<String, String>>()
                        self.majors[m]![c.key.uppercased()] = c.value
                    }
                }
            }
            self.majorsTable.reloadData()
        })
    }
}
