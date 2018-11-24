//
//  MajorsTableView.swift
//  PickMe
//
//  Created by Alan zhang on 2018/11/23.
//  Copyright © 2018 z.luo. All rights reserved.
//

// This table view aims to display the majors.

import UIKit

class MajorsTableView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var majorsTable: UITableView!
    
    var majors : [String] = ["A","B","C"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        majorsTable.dataSource = self
        majorsTable.delegate = self
        
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
        
        myCell?.textLabel!.text = majors[indexPath.row]
        
        return myCell!
        
    }
    
    var majorSeletced : String!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        majorSeletced = majors[indexPath.row]
        self.performSegue(withIdentifier: "MajorToCourses", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! CoursesTableView
        destination.major = majorSeletced
        
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
