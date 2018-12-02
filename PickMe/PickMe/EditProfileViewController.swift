//
//  EditProfileViewController.swift
//  PickMe
//
//  Created by ShaneTong on 11/29/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseUI

class EditProfileViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var firstMajorField: UITextField!
    @IBOutlet var secondMajorField: UITextField!
    @IBOutlet var minorField: UITextField!
    
    var majorArray = [String]()
    var minorArray = [String]()
    
    override func viewDidLoad() {
        reloadAllData()
        super.viewDidLoad()
        majorArray.append("None")
        minorArray.append("None")
        majorArray.append("Undecided")
        grabData()
        setupPickerView()
        setupImageView()
        // Do any additional setup after loading the view.
    }
    
    //reload data
    func reloadAllData() {
        print("reloadAllData")
        reloadNameAndMajor()
        reloadImage()
    }
    
    func reloadNameAndMajor() {
        print("reloadNameAndMajor")
        nameField.text = Auth.auth().currentUser?.displayName != nil ? Auth.auth().currentUser?.displayName! : "Anonymous"
        let ref = Database.database().reference()
        ref.observe(.value, with: {
            snapshot in
            var profile_data = (snapshot.value! as! Dictionary<String, Any>)["profile"] as! Dictionary<String, Dictionary<String, Any>>
            if profile_data.keys.contains((Auth.auth().currentUser?.uid)!) {
                if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("first") {
                    self.firstMajorField.text = profile_data[(Auth.auth().currentUser?.uid)!]!["first"] as? String
                }
                if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("second") {
                    self.secondMajorField.text = profile_data[(Auth.auth().currentUser?.uid)!]!["second"] as? String
                }
                if profile_data[(Auth.auth().currentUser?.uid)!]!.keys.contains("minor") {
                    self.minorField.text = profile_data[(Auth.auth().currentUser?.uid)!]!["minor"] as? String
                }
            }
        })
    }
    
    func reloadImage() {
        print("reloadImage")
        let placeholderImage = UIImage(named: "POI")
        let storageRef = Storage.storage().reference()
        let uid = Auth.auth().currentUser?.uid
        let downloadRef = storageRef.child("user/\(uid!)")
        imageView.sd_setImage(with: downloadRef, placeholderImage: placeholderImage)
    }
    
    //image view function begins
    func setupImageView() {
        imageView.layer.cornerRadius = imageView.bounds.height/2
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(importImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTap)
    }

    @objc func importImage() {
        print("Inside import image")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        if let theImage = selectedImage {
            imageView.image = theImage
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonClicked(_ sender: UIButton) {
        submitInfo()
        UserDefaults.standard.set([firstMajorField.text, secondMajorField.text, minorField.text], forKey: "majorMinor")
        self.performSegue(withIdentifier: "backToProfileSegue", sender: self)
    }
    
    func submitInfo() {
        //Upload to Storage
        if let theImage = imageView.image {
            self.uploadToStorage(theImage, completion: {url in
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.nameField.text
                changeRequest?.photoURL = url
                
                changeRequest?.commitChanges(completion: { error in
                    if error == nil {
                        print("Update success")
                    }
                    else {
                        print("Error!")
                    }
                })
            })
        }
        else {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = self.nameField.text
            
            changeRequest?.commitChanges(completion: { error in
                if error == nil {
                    print("Update success")
                }
                else {
                    print("Error!")
                }
            })
        }
        let firstMajorString = firstMajorField.text != nil ? firstMajorField.text! : "None"
        let secondMajorString = secondMajorField.text != nil ?  secondMajorField.text! : "None"
        let minorString = minorField.text != nil ?  minorField.text! : "None"
        let ref = Database.database().reference()
        ref.child("profile").child((Auth.auth().currentUser?.uid)!).child("first").setValue(firstMajorString)
        ref.child("profile").child((Auth.auth().currentUser?.uid)!).child("second").setValue(secondMajorString)
        ref.child("profile").child((Auth.auth().currentUser?.uid)!).child("minor").setValue(minorString)
    }
    
    func uploadToStorage(_ image: UIImage, completion: @escaping ((_ url:URL?)->())){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        guard let imageData = UIImageJPEGRepresentation(image, 0.75) else {return}
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData, metadata: metaData, completion: { (metadata, error) in
            guard let metadata = metadata else {
                print("Upload error")
                return
            }
            storageRef.downloadURL(completion: {(url, error) in
                if url != nil {
                    completion(url)
                }
                else {
                    return
                }
            })
        })
    }
    
    //pickerview function begins
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if minorField.isFirstResponder {
            return minorArray.count
        }
        else {
            return majorArray.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if minorField.isFirstResponder {
            return minorArray[row]
        }
        else {
            return majorArray[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if firstMajorField.isFirstResponder {
            firstMajorField.text = majorArray[row]
        }
        if secondMajorField.isFirstResponder {
            secondMajorField.text = majorArray[row]
        }
        if minorField.isFirstResponder {
            minorField.text = minorArray[row]
        }
    }
    
    func setupPickerView() {
        let pickerMajor = UIPickerView()
        pickerMajor.dataSource = self
        pickerMajor.delegate = self
        let pickerMinor = UIPickerView()
        pickerMinor.dataSource = self
        pickerMinor.delegate = self
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditProfileViewController.donePicker))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        firstMajorField.inputView = pickerMajor
        secondMajorField.inputView = pickerMajor
        minorField.inputView = pickerMinor
        firstMajorField.inputAccessoryView = toolBar
        secondMajorField.inputAccessoryView = toolBar
        minorField.inputAccessoryView = toolBar
        print("Finish setup picker")
        
    }
    
    @objc func donePicker() {
        if (firstMajorField.isFirstResponder) {
            firstMajorField.resignFirstResponder()
        }
        if (secondMajorField.isFirstResponder) {
            secondMajorField.resignFirstResponder()
        }
        if (minorField.isFirstResponder) {
            minorField.resignFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //grab data function
    func grabData() {
        let ref = Database.database().reference()
        
        ref.observe(.value, with: {
            snapshot in
            let requirements = (snapshot.value! as! Dictionary<String, Any>)["requirements"] as! Array<Dictionary<String, String>>
            for i in requirements {
                let name = i["name"]!
                if name.hasSuffix("(Minor)") {
                    self.minorArray.append(name)
                }
                else {
                    self.majorArray.append(name)
                }
            }
            
        })
        print("Finish grab data")
    }
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! UserProfileViewController
        destination.backFromEdit = true
    }
}
