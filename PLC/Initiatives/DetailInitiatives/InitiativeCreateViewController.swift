//
//  InitiativeCreateViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 6/27/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import FirebaseStorage
import PhotosUI

class InitiativeCreateViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var participateCheck: UIButton!
    @IBOutlet weak var leadCheck: UIButton!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var addImageLabel: UILabel!
    @IBOutlet weak var leadAmountTextField: UITextField!
    @IBOutlet weak var participateAmountTextField: UITextField!
    @IBOutlet weak var validationCheckBoxLabel: UILabel!
    @IBOutlet weak var taskPhotoImageView: UIImageView!
    
    @IBOutlet weak var fundingCheck: UIButton!

    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    let categoryPickerView = UIPickerView()
    let categories: [String] = ["Fun & Games", "Philanthropy", "Shared Interests", "Skill Building", "Other"]
    var task: Task?
    var eventTime: TimeInterval = 0.0
    var eventEndTime: TimeInterval = 0.0
    var taskPhoto: UIImage = UIImage()
    var taskPhotoURL: NSURL = NSURL()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initial Setup For Creation Page
        taskPhotoImageView.isHidden = true
        validationCheckBoxLabel.text = ""
        leadAmountTextField.isEnabled = false
        participateAmountTextField.isEnabled = false
        
        startDatePicker.datePickerMode = UIDatePickerMode.dateAndTime
        endDatePicker.datePickerMode = UIDatePickerMode.dateAndTime
        
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        
        timeTextField.inputView = startDatePicker
        endTimeTextField.inputView = endDatePicker
        categoryTextField.inputView = categoryPickerView
        
        fundingCheck.setImage(#imageLiteral(resourceName: "iconCheckedBox"), for: .selected)
        
        startDatePicker.addTarget(self, action: #selector(datePickerChanged), for:UIControlEvents.valueChanged)
        endDatePicker.addTarget(self, action: #selector(datePickerChanged), for:UIControlEvents.valueChanged)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Actions
    @IBAction func addImageButton(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    @IBAction func leadCheckBox(_ sender: UIButton) {
        //Unchecks and checks box
        sender.isSelected = !sender.isSelected
        //If checked, the amount textfield is enabled
        if (sender.isSelected){
            leadAmountTextField.isEnabled = true
        }
        else{
            leadAmountTextField.isEnabled = false
        }
    }
    @IBAction func participateCheckBox(_ sender: UIButton) {
        //Unchecks and checks box
        sender.isSelected = !sender.isSelected
        //If checked, the amount textfield is enabled
        if (sender.isSelected){
            participateAmountTextField.isEnabled = true
        }
        else{
            participateAmountTextField.isEnabled = false
        }
    }
    @IBAction func fundingCheckBox(_ sender: UIButton) {
        //Unchecks and checks box
        sender.isSelected = !sender.isSelected
    }
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss()
    }
    @IBAction func createButton(_ sender: UIButton) {
        let valid = validate()
        if (valid){
            var amounts = Dictionary<String, Int>()
            var tagResult: String = ""
            var participantAmount = 0
            var leaderAmount = 0
            //Appends amount of leaders needed, if check box is checked
            if leadCheck.isSelected {
                leaderAmount = Int(leadAmountTextField.text!)!
                if tagResult == ""{
                    tagResult.append("#lead")
                }
                else{
                    tagResult.append(" #lead")
                }
                amounts["leaders"] = leaderAmount
            }
            //Appends amount of participants needed, if check box is checked
            if participateCheck.isSelected {
                participantAmount = Int(participateAmountTextField.text!)!
                if tagResult == ""{
                    tagResult.append("#participate")
                }
                else{
                    tagResult.append(" #participate")
                }
                amounts["participants"] = participantAmount
            }
            
            let key = Constants.refs.databaseTasks.childByAutoId().key
            var taskTitle: String
            
            //Creates a pending task, if funding check box is checked
            if fundingCheck.isSelected{
                Constants.refs.databaseUsers.child(currentUser.uid).child("tasks_pending").child(key).setValue(true)
                
                Constants.refs.databasePendingTasks.child(key).setValue(["taskID": key, "taskTimeMilliseconds": task?.timeMilliseconds as Any, "taskEndTimeMilliseconds": task?.endTimeMilliseconds as Any])
                taskTitle = titleTextField.text!
            }
            else{
                taskTitle = titleTextField.text!
            }
            
            //Creates new task
            task = Task(title: taskTitle, description: descriptionTextField.text!, tag: tagResult, startTime: timeTextField.text!, endTime: endTimeTextField.text!, location: locationTextField.text!, timestamp: NSDate().timeIntervalSince1970, id: key, createdBy: currentUser.uid, ranking: 0, timeMilliseconds: eventTime, endTimeMilliseconds: eventEndTime, amounts: amounts, usersLikedAmount: 0, category: categoryTextField.text!)
            
            //Adds task to database
            let taskDB = ["taskId": key, "taskTitle": task?.title as Any, "taskDescription": task?.description as Any, "taskTag": task?.tag as Any, "taskTime": task?.startTime as Any, "taskEndTime": task?.endTime as Any, "taskLocation": task?.location as Any as Any, "timestamp": task?.timestamp as Any, "createdBy" : task?.createdBy as Any, "ranking": task?.ranking as Any, "taskTimeMilliseconds": task?.timeMilliseconds as Any, "taskEndTimeMilliseconds": task?.endTimeMilliseconds as Any, "participantAmount": participantAmount, "leaderAmount": leaderAmount, "usersLikedAmount": task?.usersLikedAmount as Any, "category": task?.category as Any] as [String : Any]
            
                Constants.refs.databaseTasks.child(key).setValue(taskDB)
            
            //Adds task to pendingTasks list in database if check box is checked for funding
            if fundingCheck.isSelected{
                Constants.refs.databasePendingTasks.child(key).setValue(["taskID": key, "taskTimeMilliseconds": task?.timeMilliseconds as Any, "taskEndTimeMilliseconds": task?.endTimeMilliseconds as Any])
            }
            else{
                //Adds task to upcomingTasks
                Constants.refs.databaseUpcomingTasks.child(key).setValue(["taskID": key, "taskTimeMilliseconds": task?.timeMilliseconds as Any, "taskEndTimeMilliseconds": task?.endTimeMilliseconds as Any])
                
                //Adds task to user under tasks_created
                let tasksCreated = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_created")
                tasksCreated.child(key).setValue(true)
                
                //Gives points to user for creation
                let point = Points()
                Constants.refs.databaseUsers.child(currentUser.uid).child("points").setValue(currentUser.points + point.getPoints(type: "Create", thisTask: task))
            }
            
            //Stores image in Firebase Storage if user adds an image to the egg
            if (addImageLabel.text != "Add Image"){
                let imageName:String = String("\(key).png")
                
                let storageRef = Constants.refs.storage.child("taskPhotos/\(imageName)")
                if let uploadData = UIImageJPEGRepresentation(taskPhoto, CGFloat(0.50)){
                    storageRef.putData(uploadData, metadata: nil
                        , completion: { (metadata, error) in
                            if error != nil {
                                return
                            }
                    })
                    
                }
            }
            dismiss()
            
            
        }
    }
    
    //MARK: Date Picker
    @objc func datePickerChanged(datePicker:UIDatePicker) {
        if datePicker == startDatePicker{
            eventTime = datePicker.date.timeIntervalSince1970
            endDatePicker.minimumDate = datePicker.date
            timeTextField.text = format(datePicker: datePicker)
        }
        else{
            eventEndTime = datePicker.date.timeIntervalSince1970
            endTimeTextField.text = format(datePicker: datePicker)
        }
    }
    
    //Helper Function for Date Picker
    private func format(datePicker:UIDatePicker) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateStyle = DateFormatter.Style.medium
        return dateFormatter.string(from:datePicker.date)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ _picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        taskPhoto = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        taskPhotoImageView.isHidden = false
        taskPhotoImageView.image = taskPhoto
        taskPhotoURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        let imageName = taskPhotoURL.lastPathComponent
        addImageLabel.text = imageName
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: UIPickerViewDataSource methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    //MARK: UIPickerViewDelegates methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = "\(categories[pickerView.selectedRow(inComponent: 0)])"
    }
    
    //MARK: Helper Functions
    private func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //Checks to make sure all necessary fields are filled out and filled out correctly
    private func validate() -> Bool{
        var valid:Bool = true
        if (titleTextField.text?.isEmpty)! {
            //Change the placeholder color to P.S. red
            titleTextField.attributedPlaceholder = NSAttributedString(string: "Please enter Task Title", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 218.0/255.0, green: 73.0/255.0, blue: 82.0/255.0, alpha: 1.0)])
            valid = false
        }
        if (descriptionTextField.text?.isEmpty)!{
            //Change the placeholder color to P.S. red
            descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Please enter Task Description", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 218.0/255.0, green: 73.0/255.0, blue: 82.0/255.0, alpha: 1.0)])
            valid = false
        }
        if (timeTextField.text?.isEmpty)!{
            //Change the placeholder color to P.S. red
            timeTextField.attributedPlaceholder = NSAttributedString(string: "Please enter a Start Time", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 218.0/255.0, green: 73.0/255.0, blue: 82.0/255.0, alpha: 1.0)])
            valid = false
        }
        if (endTimeTextField.text?.isEmpty)!{
            //Change the placeholder color to P.S. red
            endTimeTextField.attributedPlaceholder = NSAttributedString(string: "Please enter an End Time", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 218.0/255.0, green: 73.0/255.0, blue: 82.0/255.0, alpha: 1.0)])
            valid = false
        }
        if (locationTextField.text?.isEmpty)!{
            //Change the placeholder color to P.S. red
            locationTextField.attributedPlaceholder = NSAttributedString(string: "Please enter a Location", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 218.0/255.0, green: 73.0/255.0, blue: 82.0/255.0, alpha: 1.0)])
            valid = false
        }
        if (categoryTextField.text?.isEmpty)!{
            //Change the placeholder color to P.S. red
            categoryTextField.attributedPlaceholder = NSAttributedString(string: "Please select a Category", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 218.0/255.0, green: 73.0/255.0, blue: 82.0/255.0, alpha: 1.0)])
            valid = false
        }
        if !(leadCheck.isSelected) && !(participateCheck.isSelected){
            validationCheckBoxLabel.textColor = UIColor(red: 218.0/255.0, green: 73.0/255.0, blue: 82.0/255.0, alpha: 1.0)
            validationCheckBoxLabel.text =  "'People Needed' not complete"
            valid = false
        }
        else{
            if ((leadAmountTextField.isEnabled) && (leadAmountTextField.text?.isEmpty)!) || ((participateAmountTextField.isEnabled) && (participateAmountTextField.text?.isEmpty)!){
                validationCheckBoxLabel.textColor = UIColor(red: 218.0/255.0, green: 73.0/255.0, blue: 82.0/255.0, alpha: 1.0)
                validationCheckBoxLabel.text =  "'People Needed' not complete"
            }
            else{
                validationCheckBoxLabel.text = ""
            }
        }
        return valid
    }
    
    
}
