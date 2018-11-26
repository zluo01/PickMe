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
    
    var allMajors = [String]()
    var allMajorsLink = [String]()
    
    var filteredMajors = [String]()
    var filteredMajorsLink = [String]()
    
    var filtered = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered ? filteredMajors.count :allMajors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myCell = tableView.dequeueReusableCell(withIdentifier: "theCell")
        
        if myCell == nil {
            myCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "theCell")
        }
        
        myCell?.textLabel!.text = filtered ? filteredMajors[indexPath.row] : allMajors[indexPath.row]
        return myCell!
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        majorTable.dataSource = self
        majorTable.delegate = self
        filterSearchBar.delegate = self
        fetchDataFromDatabase()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wvcontroller = WebViewController()
        wvcontroller.urlString = filtered ? filteredMajorsLink[indexPath.row] : allMajorsLink[indexPath.row]
        self.navigationController?.pushViewController(wvcontroller, animated: true)
    }

    func fetchDataFromDatabase() {
        let ref = Database.database().reference()
        
        ref.observe(.value, with: {
            snapshot in
            let requirements = (snapshot.value! as! Dictionary<String, Any>)["requirements"] as! Array<Dictionary<String, String>>
            for i in requirements {
                if (i["name"] != nil && i["link"] != nil) {
                    self.allMajors.append(i["name"]!)
                    self.allMajorsLink.append(i["link"]!)
                }
            }
            print(self.allMajors.count)
            print(self.allMajors[0])
            self.majorTable.reloadData()
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMajors = allMajors.filter({$0.prefix(searchText.count) == searchText})
        filteredMajorsLink = []
        for i in filteredMajors {
            let index = allMajors.index(of: i)
            filteredMajorsLink.append(allMajorsLink[index!])
        }
        filtered = true
        majorTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filtered = false
        searchBar.text! = ""
        majorTable.reloadData()
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
