//
//  CoursesTableView.swift
//  PickMe
//
//  Created by Alan zhang on 2018/11/23.
//  Copyright © 2018 z.luo. All rights reserved.
//

// This table view aims to display the courses.

import UIKit

class CoursesTableView: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var coursesTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var courses : [String: [String: String]] = [:]
    var displayCourses : [String: [String: String]] = [:]
    var courseSeletced : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        coursesTable.dataSource = self
        coursesTable.delegate = self
        searchBar.delegate = self
        
        displayCourses = courses
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange: String) {
        self.coursesTable.reloadData()
        
        DispatchQueue.global(qos: .userInitiated).async {
            if (!textDidChange.isEmpty) {
                self.displayCourses = self.courses.filter { $0.key.uppercased().contains(textDidChange.uppercased()) ||  ($0.value["title"]?.uppercased().contains(textDidChange.uppercased()))!}
            } else {
                self.displayCourses = self.courses
            }
            DispatchQueue.main.async {
                self.coursesTable.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myCell = tableView.dequeueReusableCell(withIdentifier: "theCell")
        
        if myCell == nil {
            myCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "theCell")
        }
        print("\(Array(displayCourses.keys).sorted()) => \(indexPath.row)")
        let course_id = Array(displayCourses.keys).sorted()[indexPath.row]
        myCell?.textLabel!.text =  course_id
        myCell?.detailTextLabel?.text = " - " + displayCourses[course_id]!["title"]!
        
        return myCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        courseSeletced = Array(displayCourses.keys).sorted()[indexPath.row]
        self.performSegue(withIdentifier: "CoursesToCourse", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SingleCourseDetails
        destination.details = courses[courseSeletced]
    } 
}
