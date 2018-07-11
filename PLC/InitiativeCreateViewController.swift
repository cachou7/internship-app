//
//  InitiativeCreateViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 6/27/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class InitiativeCreateViewController: UIViewController, UITextFieldDelegate {
    //MARK: Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var participateCheck: UIButton!
    @IBOutlet weak var leadCheck: UIButton!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var bigIdeaButton: UIButton!
    @IBOutlet weak var communityButton: UIButton!
    @IBOutlet weak var leadAmountTextField: UITextField!
    @IBOutlet weak var participateAmountTextField: UITextField!
    @IBOutlet weak var validationButtonLabel: UILabel!
    @IBOutlet weak var validationCheckBoxLabel: UILabel!
    
    //MARK: Variables
    let datePicker = UIDatePicker()
    var task: Task?
    var eventTime: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validationCheckBoxLabel.isEnabled = false
        validationButtonLabel.isEnabled = false
        bigIdeaButton.isSelected = false
        communityButton.isSelected = false
        leadAmountTextField.isEnabled = false
        participateAmountTextField.isEnabled = false
        
        
        datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        timeTextField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePickerChanged), for:UIControlEvents.valueChanged)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func bigIdeaAction(_ sender: UIButton) {
        communityButton.isSelected = false
        bigIdeaButton.isSelected = true
        bigIdeaButton.backgroundColor = UIColor.white
        communityButton.backgroundColor = UIColor.lightGray
    }
    @IBAction func communityAction(_ sender: UIButton) {
        bigIdeaButton.isSelected = false
        communityButton.isSelected = true
        communityButton.backgroundColor = UIColor.white
        bigIdeaButton.backgroundColor = UIColor.lightGray
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
            var type: String
            var participantAmount = "0"
            var leaderAmount = "0"
            if leadCheck.isSelected {
                leaderAmount = leadAmountTextField.text!
                if tagResult == ""{
                    tagResult.append("#lead")
                }
                else{
                    tagResult.append(" #lead")
                }
                amounts["leaders"] = Int(leaderAmount)
            }
            if participateCheck.isSelected {
                participantAmount = participateAmountTextField.text!
                if tagResult == ""{
                    tagResult.append("#participate")
                }
                else{
                    tagResult.append(" #participate")
                }
                amounts["participants"] = Int(participantAmount)
            }
            if bigIdeaButton.isSelected {
                type = "Big Idea"
            }
            else{
                type = "Community"
            }
            
            let interval = NSDate().timeIntervalSince1970
            let key = Constants.refs.databaseTasks.childByAutoId().key
            
            task = Task(title: titleTextField.text!, description: descriptionTextField.text!, tag: tagResult, time: timeTextField.text!, location: locationTextField.text!, timestamp: String(interval), id: key, createdBy: currentUser.uid, ranking: "0", timeMilliseconds: eventTime!, type: type, amounts: amounts)
            
            let taskDB = ["taskId": key, "taskTitle": task?.title, "taskDescription": task?.description, "taskTag": task?.tag, "taskTime": task?.time, "taskLocation": task?.location, "timestamp": task?.timestamp, "createdBy" : task?.createdBy, "ranking": task?.ranking, "taskTimeMilliseconds": task?.timeMilliseconds, "taskType": task?.type, "participantAmount": participantAmount, "leaderAmount": leaderAmount]
        Constants.refs.databaseTasks.child(key).setValue(taskDB)
            
            let tasksCreated = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_created")
            tasksCreated.child("taskId").setValue(key)
            print("Task added")
            dismiss()
        }
    }
    
    //MARK: Date Picker
    @objc func datePickerChanged(datePicker:UIDatePicker) {
        let dateFormatter = DateFormatter()
        eventTime = String(self.datePicker.date.timeIntervalSince1970)
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateStyle = DateFormatter.Style.medium
        let strDate = dateFormatter.string(from:datePicker.date)
        timeTextField.text = strDate
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
            timeTextField.attributedPlaceholder = NSAttributedString(string: "Please enter a Time", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if (locationTextField.text?.isEmpty)!{
            // Change the placeholder color to red for textfield passWord
            locationTextField.attributedPlaceholder = NSAttributedString(string: "Please enter a Location", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if !(leadCheck.isSelected) && !(participateCheck.isSelected){
            validationCheckBoxLabel.isEnabled = true
            validationCheckBoxLabel.attributedText = NSAttributedString(string: "Please select '#lead' and/or '#participate'", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        if !(bigIdeaButton.isSelected) && !(communityButton.isSelected){
            validationButtonLabel.isEnabled = true
            validationButtonLabel.attributedText = NSAttributedString(string: "Please select 'Big Idea' or 'Community'", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            valid = false
        }
        else{
            validationButtonLabel.text?.removeAll()
            validationButtonLabel.isEnabled = false
        }
        if ((leadAmountTextField.isEnabled) && (leadAmountTextField.text?.isEmpty)!) || ((participateAmountTextField.isEnabled) && (participateAmountTextField.text?.isEmpty)!){
            validationCheckBoxLabel.attributedText = NSAttributedString(string: "Please enter amount of task leaders/participants", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
        }
        else{
            validationCheckBoxLabel.text?.removeAll()
            validationCheckBoxLabel.isEnabled = false
        }
        return valid
    }
    
    
}
