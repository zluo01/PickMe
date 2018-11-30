//
//  singleCourseDetails.swift
//  PickMe
//
//  Created by Alan zhang on 2018/11/23.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SingleCourseDetails: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let semesters = ["1","2","3","4","5","6","7","8"]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return semesters.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return semesters[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        semesterField.text = semesters[row]
    }
    
    @IBOutlet weak var courseId: UILabel!
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var courseDes: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var semesterField: UITextField!
    @IBOutlet var addClassButton: UIButton!
    //var course : String!
    var details : [String: String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        courseId.text = details["course_code"]
        courseTitle.text = details["title"]
        courseDes.text = details["description"]
        
        courseId.sizeToFit()
        courseTitle.sizeToFit()
        courseDes.sizeToFit()
        
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: courseDes.bottomAnchor).isActive = true
        createPicker()
    }
    
    func createPicker() {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        semesterField.inputView = picker
    }

    @IBAction func addClassAction(_ sender: UIButton) {
        if semesterField.text == "" || semesterField.text == nil {
            let alertController = UIAlertController(title: "Empty Field", message: "Please indicate in which semester of your 8 semesters you took this class", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            addClass(courseId.text!, semesterField.text!)
        }
    }
    func addClass(_ courseCode:String, _ semester:String) {
        print("Called addClass")
        if Auth.auth().currentUser != nil {
           
            semesterField.resignFirstResponder()
            let ref = Database.database().reference()
            
            ref.observe(.value, with: {
                snapshot in
                let users = (snapshot.value! as! Dictionary<String, Any>)["users"] as! Dictionary<String, Dictionary<String, String>>
                let currentUser = Auth.auth().currentUser!
                if users.keys.contains(currentUser.uid) {
                    var userDict = users[currentUser.uid]!
                    var added = false
                    if userDict.keys.contains(courseCode) && userDict[courseCode] != semester{
                        print("In if")
                        let alertController = UIAlertController(title: "Class Already Added", message: "You have already added this class.", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else {
                        print("In else")
                        userDict[courseCode] = semester
                        ref.child("users").child(currentUser.uid).setValue(userDict)
                        added = true
                    }
                }
                else {
                    var newDict = Dictionary<String, String>()
                    newDict[courseCode] = semester
                    ref.child("users").child(currentUser.uid).setValue(newDict)
                }
            })
        }
        else {
            let alertController = UIAlertController(title: "Operation Not Allowed", message: "You have to log in first.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
