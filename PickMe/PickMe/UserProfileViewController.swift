//
//  UserProfileViewController.swift
//  PickMe
//
//  Created by Harry Wei on 11/25/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseUI
import FirebaseDatabase
import ExpandingMenu

class UserProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITableViewDataSource, UITableViewDelegate, FUIAuthDelegate{
    
    @IBOutlet weak var myImageView: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var firstMajorLabel: UILabel!
    @IBOutlet weak var secondMajorLabel: UILabel!
    @IBOutlet weak var userActionButton: UIBarButtonItem!
    
    @IBOutlet var minorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var backFromEdit = false
    
    //    var takens : [[String]] = [[]]
    //    var favs : [String] = []
    var array = [[String]]()
    var seg = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // first time major minor, create container
        if UserDefaults.standard.stringArray(forKey: "majorMinor") == nil{
            UserDefaults.standard.set(["None","None","None"], forKey: "majorMinor")
        }
        reloadAllData()
        
        // create following buttons
        configureExpandingMenuButton()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.lightGray
        loadArray()
        print(array)
        UserDefaults.standard.synchronize()
        tableView.reloadData()
        // Todo display class taken or favor class table view
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            userActionButton.title = "Login"
        } else { // Todo double check here
            userActionButton.title = "Log out"
        }
        if backFromEdit {
            let alertController = UIAlertController(title: "Profile Update Success", message: "You have successfully updated your profile!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            backFromEdit = false
        }
        (seg == 1) ? loadFav() : loadArray()
        tableView.reloadData()
    }
    
    //Todo implement
    @IBAction func tableSwitch(_ sender: UISegmentedControl) {
        seg = sender.selectedSegmentIndex
        (sender.selectedSegmentIndex == 0) ? loadArray() : loadFav()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myCell = tableView.dequeueReusableCell(withIdentifier: "theCell")
        
        if myCell == nil {
            myCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "theCell")
        }
        myCell?.backgroundColor = UIColor.lightGray
        if ( array[indexPath.row].count != 0){
            
            myCell?.textLabel!.text = array[indexPath.row][0]
            
            if(seg == 0){
                myCell?.detailTextLabel!.text = "Taken at semester \(array[indexPath.row][1]) "
            }
            else{
                myCell?.detailTextLabel!.text = ""
            }
        }
        return myCell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            var deleted = array.remove(at: indexPath.row)
            var courses : [String] = []
            
            if(seg == 0){
                for eachC in array{
                    if(eachC[1] == deleted[1]){
                        courses.append(eachC[0])
                    }
                }
                UserDefaults.standard.set(courses, forKey: String(deleted[1]))
            } else{
                for eachC in array{
                    courses.append(eachC[0])
                }
                UserDefaults.standard.set(courses, forKey: "fav")
            }
            UserDefaults.standard.synchronize()
            tableView.reloadData()
            
            if (isLogIn()) {
                upLoadDelete()
            }
            
        }
        
    }
    
    func upLoadDelete(){
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
            ref.child("profile").child(Auth.auth().currentUser!.uid).child("favorites").setValue(getFav())
        }
    }
    
    // Todo implement login logout
    @IBAction func userActions(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            // go to login page
            // identifer is ProfileToLogin
            let authUI = FUIAuth.defaultAuthUI()
            guard authUI != nil else {
                return
            }
            authUI?.delegate = self
            let authViewController = authUI!.authViewController()
            present(authViewController, animated: true, completion: nil)
            
        } else { // logout here
            let authUI = FUIAuth.defaultAuthUI()
            do {
                try authUI?.signOut()
                let alertController = UIAlertController(title: "Logout Success", message: "You have successfully logged out!", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                print("You have logged out!")
                reloadAllData()
                userActionButton.title = "Login"
                
                UserDefaults.standard.set(["false"], forKey: "login")
                UserDefaults.standard.synchronize()
                print((UserDefaults.standard.stringArray(forKey: "login") ?? [String]())[0].compare("false").rawValue)
                print("i am fucing here morons \(isLogIn())")
                
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error != nil {
            return
        }
        UserDefaults.standard.set(["true"], forKey: "login")
        
        print(isLogIn())
        UserDefaults.standard.synchronize()
        //reload all data
       
        reloadAllData()
        
        tableView.reloadData()
    }
    
    func reloadAllData() {
        //        print("reloadAllData")
        reloadNameAndMajor()
        reloadImage()
    }
    
    func reloadNameAndMajor() {
        //        print("reloadNameAndMajor")
        if Auth.auth().currentUser == nil {
            firstMajorLabel.text = getMajorMinor(0)
            secondMajorLabel.text = getMajorMinor(1)
            minorLabel.text = getMajorMinor(2)
            name.text = "Guest"
        }
        else {
            name.text = Auth.auth().currentUser?.displayName != nil ? Auth.auth().currentUser?.displayName! : "Anonymous"
            
            let ref = Database.database().reference()
            ref.observe(.value, with: {
                snapshot in
                var profile_data = (snapshot.value! as! Dictionary<String, Any>)["profile"] as! Dictionary<String, Dictionary<String, Any>>
                if profile_data.keys.contains((Auth.auth().currentUser?.uid)!) { // has profile data on database
                    if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("first") {
                        self.firstMajorLabel.text = profile_data[(Auth.auth().currentUser?.uid)!]!["first"] as? String
                    }
                    if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("second") {
                        self.secondMajorLabel.text = profile_data[(Auth.auth().currentUser?.uid)!]!["second"] as? String
                    }
                    if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("minor") {
                        self.minorLabel.text = profile_data[(Auth.auth().currentUser?.uid)!]!["minor"] as? String
                    }
                    if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("favorites") {
                        var favors = [String]()
                        for i in profile_data[(Auth.auth().currentUser?.uid)!]!["favorites"] as! [String]{
                            if (i != "DUMMY") {
                                favors.append(i)
                            }
                        }
                        UserDefaults.standard.set(favors , forKey: "fav")
                    }
                    if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("taken") {
                        var taken : [Int : [String]] = [ 1 : [], 2 : [], 3 : [], 4:[],5:[],6:[],7:[],8:[]]
                        for (semester, course) in profile_data[(Auth.auth().currentUser?.uid)!]!["taken"] as! Dictionary<String, String> {
                            if ( course != "DUMMY" ){
                                let s = Int(semester[...0])!
                                taken[s]!.append(course)
                            }
                        }
                        
                        for i in 1...8 {
                            UserDefaults.standard.set(taken[i] , forKey: String(i))
                        }
                    }

                } else { // create container on the database
                    let currentUser = Auth.auth().currentUser!
                    var dict = Dictionary<String, Any>()
                    dict["first"] = "None"
                    dict["second"] = "None"
                    dict["minor"] = "None"
                    dict["favorites"] = ["DUMMY"]
                    dict["taken"] = ["10" : "DUMMY"]
                    ref.child("profile").child(currentUser.uid).setValue(dict)
                }
            })
        }
    }
    
    func reloadImage() {
        //        print("reloadImage")
        if Auth.auth().currentUser == nil {
            myImageView.image = UIImage(named: "POI")
        }
        else {
            let placeholderImage = UIImage(named: "POI")
            let storageRef = Storage.storage().reference()
            let uid = Auth.auth().currentUser?.uid
            let downloadRef = storageRef.child("user/\(uid!)")
            myImageView.sd_setImage(with: downloadRef, placeholderImage: placeholderImage)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func configureExpandingMenuButton() {
        let menuButtonSize: CGSize = CGSize(width: 64.0, height: 64.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), image: UIImage(named: "chooser-button-tab")!, rotatedImage: UIImage(named: "chooser-button-tab-highlighted")!)
        menuButton.center = CGPoint(x: self.view.bounds.width - 32.0, y: self.view.bounds.height - 72.0)
        self.view.addSubview(menuButton)
        
        let edit = ExpandingMenuItem(size: menuButtonSize, title: "Edit", image: UIImage(named: "heart")!, highlightedImage: UIImage(named: "heart-highlight")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            // add action here
            if Auth.auth().currentUser != nil {
                self.performSegue(withIdentifier: "profileToEdit", sender: self)
            }
            else {
                let alertController = UIAlertController(title: "User Not Logged In", message: "You have to log in before you can edit your profile!", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        menuButton.addMenuItems([edit])
        
        menuButton.willPresentMenuItems = { (menu) -> Void in
            //            print("MenuItems will present.")
        }
        
        menuButton.didDismissMenuItems = { (menu) -> Void in
            //            print("MenuItems dismissed.")
        }
    }
    
    func loadArray(){
        
        array = [[String]]()
        for i in 1...8 {
            if UserDefaults.standard.stringArray(forKey: String(i)) != nil{
                let courseSe = getTaken(String(i))
                for each in courseSe{
                    if(each != "DUMMY"){
                        array.append([each, String(i)])
                    }
                }
            }
        }
    }
    
    func loadFav(){
        array = []
        let favs = getFav()
        for each in favs{
            array.append([each])
        }
    }
    
    @IBAction func unwindToProfile(_ sender: UIStoryboardSegue){}
}
