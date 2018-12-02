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
import ExpandingMenu

class SingleCourseDetails: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let semesters = ["1","2","3","4","5","6","7","8"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return semesters.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: semesters[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedText = semesters[row]
    }
    
    @IBOutlet weak var courseId: UILabel!
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var courseDes: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var PickView: UIView!
    @IBOutlet weak var picker: UIPickerView!
    
    var selectedText = String()
    var details : [String: String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(PickView)
        PickView.isHidden = true
        
        // Do any additional setup after loading the view.
        courseId.text = details["course_code"]
        courseTitle.text = details["title"]
        courseDes.text = details["description"]
        
        courseId.sizeToFit()
        courseTitle.sizeToFit()
        courseDes.sizeToFit()
        
        // UIPickerView
        picker.showsSelectionIndicator = true
        picker.alpha = 0.85
        
        picker.delegate = self
        picker.dataSource = self
        
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: courseDes.bottomAnchor).isActive = true
        
        selectedText = semesters[0]
        configureExpandingMenuButton()
        
        if(isLogIn()){
            //recommend()
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        PickView.isHidden = true
    }
    
    @IBAction func addClassAction(_ sender: UIButton) {
        print(selectedText)
        addClass(courseId.text!, selectedText)
    }
    
    func addClass(_ courseCode:String, _ semester:String) {
        print("Called addClass")
        // if first time adding, create local container
        if UserDefaults.standard.stringArray(forKey: self.selectedText) == nil{
            var coursesArray : [String] = ["DUMMY"]
            coursesArray.append(details["course_code"]!)
            UserDefaults.standard.set(coursesArray, forKey: self.selectedText)
        } else{ // if already has container, direct added
            var coursesArray = UserDefaults.standard.stringArray(forKey: self.selectedText) ?? [String]()
            if(!coursesArray.contains(details["course_code"]!)){
                coursesArray.append(details["course_code"]!)
                UserDefaults.standard.set(coursesArray, forKey: self.selectedText)
            }
        }
        UserDefaults.standard.synchronize()
        
        // if user is logged in, then add to database
         print("add class \(isLogIn())")
        if (isLogIn()) {
            if Auth.auth().currentUser != nil {
                var dict = [String: String]()
                for i in 1...8 {
                    let course = getTaken(String(i))
                    if course.count > 0 {
                        for j in 0...course.count - 1 {
                            dict[String(i * 10 + j)] = course[j]
                        }
                    }
                }
                let ref = Database.database().reference()
                ref.child("profile").child(Auth.auth().currentUser!.uid).child("taken").setValue(dict)
            }
        }
        PickView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Todo calculate the recommendation
    func recommend() {
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            ref.observe(.value, with: {
                snapshot in
                let profile_data = (snapshot.value! as! Dictionary<String, Any>)["profile"] as! Dictionary<String, Dictionary<String, Any>>
                var map = [String : Int]()
                for user_id in profile_data {
                    let courses = user_id.value as! Dictionary<String, String>
                    if (courses.values.contains(self.courseId.text!)) {
                        for i in self.getSemester(courses, self.courseId.text!) {
                            for s in courses.keys {
                                if String(s[...0]) == i && courses[s]! != self.courseId.text!{
                                    if map.keys.contains(courses[s]!) {
                                        map.updateValue(map[courses[s]!]! + 1, forKey: courses[s]!)
                                    } else {
                                        map[courses[s]!] = 1
                                    }
                                }
                            }
                        }
                    }
                }
                let recommend = map.sorted(by: {$0.value >= $1.value}).dropFirst(5)
            })
        }
    }
    
    func getSemester(_ courses : [String: String], _ course : String) -> Set<String> {
        var semesters = Set<String>()
        for (s , c) in courses {
            if ( c == course ){
                semesters.insert(String(s[...0]))
            }
        }
        return semesters
    }
    
    fileprivate func configureExpandingMenuButton() {
        let menuButtonSize: CGSize = CGSize(width: 64.0, height: 64.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), image: UIImage(named: "chooser-button-tab")!, rotatedImage: UIImage(named: "chooser-button-tab-highlighted")!)
        menuButton.center = CGPoint(x: self.view.bounds.width - 32.0, y: self.view.bounds.height - 72.0)
        self.view.addSubview(menuButton)
        
        let favor = ExpandingMenuItem(size: menuButtonSize, title: "Favor", image: UIImage(named: "heart")!, highlightedImage: UIImage(named: "heart-highlight")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            favorClass()
        }
        
        let check = ExpandingMenuItem(size: menuButtonSize, title: "Check", image: UIImage(named: "check")!, highlightedImage: UIImage(named: "check-highlight")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            checkClass()
        }
        
        func checkClass() {
            PickView.isHidden = false
        }
        
        func favorClass() {
            // add to user default
            // first time favor class, create container
            if UserDefaults.standard.stringArray(forKey: "fav") == nil{
                var favArray : [String] = []
                favArray.append(details["course_code"]!)
                UserDefaults.standard.set(favArray, forKey: "fav")
            } else{ // direct added favor class
                var favArray = UserDefaults.standard.stringArray(forKey: "fav") ?? [String]()
                if(!favArray.contains(details["course_code"]!)){
                    favArray.append(details["course_code"]!)
                    UserDefaults.standard.set(favArray, forKey: "fav")
                }
            }
            
            UserDefaults.standard.synchronize()
            // if user is logged in, then add to database
            print("favor \(isLogIn())")
            if (isLogIn()) {
                if Auth.auth().currentUser != nil {
                    let ref = Database.database().reference()
                    ref.child("profile").child(Auth.auth().currentUser!.uid).child("favorites").setValue(getFav())
                }
            }
        }
        
        menuButton.addMenuItems([favor, check])
        
        menuButton.willPresentMenuItems = { (menu) -> Void in
            print("MenuItems will present.")
        }
        
        menuButton.didDismissMenuItems = { (menu) -> Void in
            print("MenuItems dismissed.")
        }
    }
}
