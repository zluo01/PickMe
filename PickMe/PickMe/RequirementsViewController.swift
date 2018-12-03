//
//  RequirementsViewController.swift
//  PickMe
//
//  Created by ShaneTong on 11/25/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RequirementsViewController: UIViewController, UITableViewDataSource,  UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var filterSearchBar: UISearchBar!
    @IBOutlet var majorTable: UITableView!
    
    var majorsMinors : [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        majorTable.dataSource = self
        majorTable.delegate = self
        filterSearchBar.delegate = self
        fetchDataFromFirebase("")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return majorsMinors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myCell = tableView.dequeueReusableCell(withIdentifier: "theCell")
        
        if myCell == nil {
            myCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "theCell")
        }
        
        myCell?.textLabel!.text = Array(majorsMinors.keys).sorted()[indexPath.row]
        if indexPath.row%2 == 0 {
            myCell?.backgroundColor = UIColor(red: 230/255, green: 244/255, blue: 242/255, alpha: 0.5)
        }
        else {
            myCell?.backgroundColor = UIColor(red: 230/255, green: 244/255, blue: 242/255, alpha: 0)
        }
        return myCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wvcontroller = WebViewController()
        wvcontroller.urlString = majorsMinors[Array(majorsMinors.keys).sorted()[indexPath.row]]
        self.navigationController?.pushViewController(wvcontroller, animated: true)
    }

    func fetchDataFromFirebase(_ keywords: String) {
        let ref = Database.database().reference()
        self.majorsMinors.removeAll()
        
        ref.observe(.value, with: {
            snapshot in
            let requirements = (snapshot.value! as! Dictionary<String, Any>)["requirements"] as! Array<Dictionary<String, String>>
            for i in requirements {
                let m = i["name"]!.uppercased()
                if keywords.isEmpty || m.contains(keywords) {
                    self.majorsMinors[i["name"]!] = i["link"]!
                }
            }
            self.majorTable.reloadData()
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange : String) {
       self.fetchDataFromFirebase(textDidChange.uppercased())
    }
}
