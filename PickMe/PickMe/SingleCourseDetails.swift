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
        // Todo add userDefault for guest users
        // no matter what should add to user default
        print("Add to user default")
        // add default code here
        
        // if user is loged in, then also add to database
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            
            ref.observe(.value, with: {
                snapshot in
                let users = (snapshot.value! as! Dictionary<String, Any>)["users"] as! Dictionary<String, Dictionary<String, String>>
                let currentUser = Auth.auth().currentUser!
                print(users)
                print(currentUser)
//                if users.keys.contains(currentUser.uid) {
//                    var userDict = users[currentUser.uid]!
//                    var added = false
//                    if userDict.keys.contains(courseCode) && userDict[courseCode] != semester{
//                        print("In if")
//                        let alertController = UIAlertController(title: "Class Already Added", message: "You have already added this class.", preferredStyle: .alert)
//                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                        alertController.addAction(cancelAction)
//                        self.present(alertController, animated: true, completion: nil)
//                    }
//                    else {
//                        print("In else")
//                        userDict[courseCode] = semester
//                        ref.child("users").child(currentUser.uid).setValue(userDict)
//                        added = true
//                    }
//                }
//                else {
//                    var newDict = Dictionary<String, String>()
//                    newDict[courseCode] = semester
//                    ref.child("users").child(currentUser.uid).setValue(newDict)
//                }
            })
        }
        PickView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Todo calculate the recommendation
    func recommend() {
        
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
            favorList[details["course_code"]!] = details
            updateFavor(favorList)
            //add to database if log in
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
