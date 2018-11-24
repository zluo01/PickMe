//
//  CoursesTableView.swift
//  PickMe
//
//  Created by Alan zhang on 2018/11/23.
//  Copyright © 2018 z.luo. All rights reserved.
//

// This table view aims to display the courses.

import UIKit

class CoursesTableView: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var coursesTable: UITableView!
    
    var courses : [String: [String: String]] = [:]
    var major : String!
    var courseSeletced : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        coursesTable.dataSource = self
        coursesTable.delegate = self
    }
    
//    func modifyCourses(){
//
//        // modify the courses array here
//        courses.append(major) // this is for test
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var myCell = tableView.dequeueReusableCell(withIdentifier: "theCell")
        
        if myCell == nil {
            myCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "theCell")
        }

        myCell?.textLabel!.text = Array(courses.keys).sorted()[indexPath.row]
        // modify here to display whether it is a required course or a selective
//        myCell?.detailTextLabel?.text = courses[indexPath.row]
        
        return myCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        courseSeletced = Array(courses.keys).sorted()[indexPath.row]
        self.performSegue(withIdentifier: "CoursesToCourse", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! SingleCourseDetails
        destination.course = courseSeletced
        
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
