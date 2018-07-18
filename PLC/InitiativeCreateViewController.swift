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

class InitiativeCreateViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //MARK: Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var participateCheck: UIButton!
    @IBOutlet weak var leadCheck: UIButton!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var addImageLabel: UILabel!
    @IBOutlet weak var leadAmountTextField: UITextField!
    @IBOutlet weak var participateAmountTextField: UITextField!
    @IBOutlet weak var validationCheckBoxLabel: UILabel!
    @IBOutlet weak var taskPhotoImageView: UIImageView!
    
    //MARK: Variables
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    var task: Task?
    var eventTime: TimeInterval = 0.0
    var eventEndTime: TimeInterval = 0.0
    var taskPhoto: UIImage = UIImage()
    var taskPhotoURL: NSURL = NSURL()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskPhotoImageView.isHidden = true
        validationCheckBoxLabel.isHidden = true
        leadAmountTextField.isEnabled = false
        participateAmountTextField.isEnabled = false
        
        
        startDatePicker.datePickerMode = UIDatePickerMode.dateAndTime
        endDatePicker.datePickerMode = UIDatePickerMode.dateAndTime
        timeTextField.inputView = startDatePicker
        endTimeTextField.inputView = endDatePicker
        startDatePicker.addTarget(self, action: #selector(datePickerChanged), for:UIControlEvents.valueChanged)
        endDatePicker.addTarget(self, action: #selector(datePickerChanged), for:UIControlEvents.valueChanged)

        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        sender.isSelected = !sender.isSelected
        if (sender.isSelected){
            leadAmountTextField.isEnabled = true
        }
        else{
            leadAmountTextField.isEnabled = false
        }
    }
    @IBAction func participateCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if (sender.isSelected){
            participateAmountTextField.isEnabled = true
        }
        else{
            participateAmountTextField.isEnabled = false
        }
    }
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss()
    }
    @IBAction func createButton(_ sender: UIBarButtonItem) {
        let valid = validate()
        if (valid){
            var amounts = Dictionary<String, Int>()
            var tagResult: String = ""
            var participantAmount = 0
            var leaderAmount = 0
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
            
            task = Task(title: titleTextField.text!, description: descriptionTextField.text!, tag: tagResult, startTime: timeTextField.text!, endTime: endTimeTextField.text!, location: locationTextField.text!, timestamp: NSDate().timeIntervalSince1970, id: key, createdBy: currentUser.uid, ranking: 0, timeMilliseconds: eventTime, endTimeMilliseconds: eventEndTime, amounts: amounts)
            
            let taskDB = ["taskId": key, "taskTitle": task?.title as Any, "taskDescription": task?.description as Any, "taskTag": task?.tag as Any, "taskTime": task?.startTime as Any, "taskEndTime": task?.endTime as Any, "taskLocation": task?.location as Any as Any, "timestamp": task?.timestamp as Any, "createdBy" : task?.createdBy as Any, "ranking": task?.ranking as Any, "taskTimeMilliseconds": task?.timeMilliseconds as Any, "taskEndTimeMilliseconds": task?.endTimeMilliseconds as Any, "participantAmount": participantAmount, "leaderAmount": leaderAmount] as [String : Any]
        Constants.refs.databaseTasks.child(key).setValue(taskDB)
            
            Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_created")
            
            Constants.refs.databaseUpcomingTasks.child(key).setValue(["taskID": key, "taskTimeMilliseconds": task?.timeMilliseconds as Any])
            
            let tasksCreated = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_created")
            tasksCreated.child(key).setValue(true)
            
            if (addImageLabel.text != "Add Image"){
                let imageName:String = String("\(key).png")
                
                let storageRef = Constants.refs.storage.child("taskPhotos/\(imageName)")
                print(storageRef)
                //let compressImage = HelperFunction.helper.resizeImage(image: taskPhoto)
                //let metadata = StorageMetadata()
               // metadata.contentType = "image/jpeg"
                // Upload the file to the path "images/rivers.jpg"
                //storageRef.putFile(from: taskPhotoURL as URL, metadata: nil) { metadata, error in
                    //guard let metadata = metadata else {
                       // return
                    //}
                //}
                if let uploadData = UIImageJPEGRepresentation(taskPhoto, CGFloat(0.50)){
                    storageRef.putData(uploadData, metadata: nil
                        , completion: { (metadata, error) in
                            if error != nil {
                                print("error")
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
        
        //print(imageName)
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
    
    private func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func validate() -> Bool{
        var valid:Bool = true
        if (titleTextField.text?.isEmpty)! {
            //Change the placeholder color to red for textfield email if
            titleTextField.attributedPlaceholder = NSAttributedString(string: "Please enter Task Title", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (descriptionTextField.text?.isEmpty)!{
            // Change the placeholder color to red for textfield userName
            descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Please enter Task Description", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (timeTextField.text?.isEmpty)!{
            // Change the placeholder color to red for textfield passWord
            timeTextField.attributedPlaceholder = NSAttributedString(string: "Please enter a start time", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (endTimeTextField.text?.isEmpty)!{
            // Change the placeholder color to red for textfield passWord
            endTimeTextField.attributedPlaceholder = NSAttributedString(string: "Please enter an end time", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (locationTextField.text?.isEmpty)!{
            // Change the placeholder color to red for textfield passWord
            locationTextField.attributedPlaceholder = NSAttributedString(string: "Please enter a Location", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if !(leadCheck.isSelected) && !(participateCheck.isSelected){
            validationCheckBoxLabel.isHidden = false
            valid = false
        }
        else{
            if ((leadAmountTextField.isEnabled) && (leadAmountTextField.text?.isEmpty)!) || ((participateAmountTextField.isEnabled) && (participateAmountTextField.text?.isEmpty)!){
                validationCheckBoxLabel.isHidden = false
            }
            else{
                validationCheckBoxLabel.isHidden = true
            }
        }
        return valid
    }
    
    
}
