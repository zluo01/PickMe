//
//  EditProfileViewController.swift
//  PickMe
//
//  Created by ShaneTong on 11/29/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import FirebaseUI

class EditProfileViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   
    

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var secondMajorField: UITextField!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var firstMajorField: UITextField!
    @IBOutlet var minorField: UITextField!
  //  @IBOutlet var picker: UIPickerView!
    var majorArray = [String]()
    var minorArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        majorArray.append("None")
        minorArray.append("None")
        majorArray.append("Undecided")
        grabData()
        setupPickerView()
        setupImageView()
        // Do any additional setup after loading the view.
    }
    
   
    
    //image view function begins
    func setupImageView() {
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
    
    func updateImage() {
        //Upload to Storage
        
    }
    
    func uploadToStorage(_ image: UIImage, clean: @escaping ((_ url:String?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let storage
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
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: "donePicker")
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
            firstMajorField.inputView = picker
            secondMajorField.inputView = picker
            minorField.inputView = picker
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
