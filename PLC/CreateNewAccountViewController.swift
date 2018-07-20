//
//  CreateNewAccountViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 7/20/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateNewAccountViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reEnterPasswordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var jobTitleTextField: UITextField!
    @IBOutlet weak var departmentTextField: UITextField!
    @IBOutlet weak var currentProjectsTextField: UITextField!
    
    var profilePic: UIImage = UIImage()
    var profilePicURL: NSURL = NSURL()
    let departmentPickerView = UIPickerView()
    let departments: [String] = ["Client Services", "CRUX", "Data Science", "Finance", "Internal", "IT", "Media", "Project Management", "Social", "Strategy & Consulting", "Technology"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //reEnterPasswordTextField.isHidden = true
        departmentPickerView.delegate = self
        departmentPickerView.dataSource = self
        departmentTextField.inputView = departmentPickerView
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width/2
        profilePhoto.layer.borderWidth = 0.1
        profilePhoto.layer.borderColor = UIColor.black.cgColor
        profilePhoto.clipsToBounds = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addNewProfilePhoto(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss()
    }
    @IBAction func saveButton(_ sender: UIButton) {
        let valid = validate()
        if (valid){
            // Creates a new user account if there are no errors
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { user, error in
                if error == nil {
                    guard let user = Auth.auth().currentUser else { return }
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.photoURL = self.profilePicURL as URL
                    currentUser = User(authData: user, firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, jobTitle: self.jobTitleTextField.text!, department: self.departmentTextField.text!, currentProjects: self.currentProjectsTextField.text!, points: 0)
                    let key = currentUser.uid
                    Constants.refs.databaseUsers.observe(.value, with: { snapshot in
                        if !snapshot.hasChild(key) {
                            print("New user added to database")
                            Constants.refs.databaseUsers.child(key).setValue(["uid": key, "firstName": currentUser.firstName, "lastName": currentUser.lastName, "jobTitle": currentUser.jobTitle, "department": currentUser.department, "currentProjects": currentUser.currentProjects, "points": 0, "tasks_created": [], "tasks_liked": []])
                        }
                    })
                }
            }
            dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func passwordEditingDidEnd(_ sender: UITextField) {
        print("password text field")
        reEnterPasswordTextField.isHidden = false
        print(reEnterPasswordTextField.becomeFirstResponder())
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ _picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profilePic = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        profilePhoto.image = profilePic
        profilePicURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UIPickerViewDataSource methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return departments.count
    }
    
    //MARK: UIPickerViewDelegates methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return departments[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        departmentTextField.text = "\(departments[pickerView.selectedRow(inComponent: 0)])"
    }
    
    
    private func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    private func validate() -> Bool{
        var valid:Bool = true
        if (emailTextField.text?.isEmpty)! || !((emailTextField.text?.contains("@"))!) || !((emailTextField.text?.contains(".com"))!) {
            emailTextField.text = nil
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Please enter a valid email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (passwordTextField.text?.isEmpty)!{
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "Please enter a valid password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (reEnterPasswordTextField.text?.isEmpty)!{
            reEnterPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Please re-enter your password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (reEnterPasswordTextField.text! != passwordTextField.text!){
            reEnterPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Password doesn't match", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (firstNameTextField.text?.isEmpty)!{
            firstNameTextField.attributedPlaceholder = NSAttributedString(string: "Please enter your first name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (lastNameTextField.text?.isEmpty)!{
            lastNameTextField.attributedPlaceholder = NSAttributedString(string: "Please enter your last name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (jobTitleTextField.text?.isEmpty)!{
            jobTitleTextField.attributedPlaceholder = NSAttributedString(string: "Please enter your job title", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (departmentTextField.text?.isEmpty)!{
            departmentTextField.attributedPlaceholder = NSAttributedString(string: "Please enter your department", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (currentProjectsTextField.text?.isEmpty)!{
            currentProjectsTextField.attributedPlaceholder = NSAttributedString(string: "Please enter your current project(s)", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        return valid
    }
    
}
