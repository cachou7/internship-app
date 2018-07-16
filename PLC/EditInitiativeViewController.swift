//
//  EditInitiativeViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 7/11/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class EditInitiativeViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var leadAmountTextField: UITextField!
    @IBOutlet weak var leadCheckBox: UIButton!
    @IBOutlet weak var participateAmountTextField: UITextField!
    @IBOutlet weak var participateCheckBox: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var validationCheckBoxLabel: UILabel!
    
    //MARK: Variables
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    var eventTime: TimeInterval = 0.0
    var eventEndTime: TimeInterval = 0.0
    var task_in:Task!
    var task_out:Task!
    var titleChanged = false
    var descriptionChanged = false
    var timeChanged = false
    var endTimeChanged = false
    var locationChanged = false
    var tagsChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTask()
        
        validationCheckBoxLabel.isHidden = true
        
        
        startDatePicker.datePickerMode = UIDatePickerMode.dateAndTime
        endDatePicker.datePickerMode = UIDatePickerMode.dateAndTime
        timeTextField.inputView = startDatePicker
        endTimeTextField.inputView = endDatePicker
        startDatePicker.addTarget(self, action: #selector(datePickerChanged), for:UIControlEvents.valueChanged)
        endDatePicker.addTarget(self, action: #selector(datePickerChanged), for:UIControlEvents.valueChanged)

        // Do any additional setup after loading the view.
    }
    
    private func configureTask(){
        titleTextField.text = task_in.title
        descriptionTextField.text = task_in.description
        timeTextField.text = task_in.startTime
        endTimeTextField.text = task_in.endTime
        locationTextField.text = task_in.location
        
        //TAGS
        leadCheckBox.isSelected = false
        leadAmountTextField.isEnabled = false
        participateCheckBox.isSelected = false
        participateAmountTextField.isEnabled = false
        let tags = task_in.tag
        let tagArray = tags.components(separatedBy: " ")
        for tag in tagArray{
            if tag == "#lead"{
                leadCheckBox.isSelected = true
                leadAmountTextField.isEnabled = true
                
                leadAmountTextField.text = String(task_in.amounts["leaders"]!)
            }
            if tag == "#participate"{
                participateCheckBox.isSelected = true
                participateAmountTextField.isEnabled = true
                participateAmountTextField.text = String(task_in.amounts["participants"]!)
            }
        }
        //END TAGS
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: Actions
    
    @IBAction func leadCheckBox(_ sender: UIButton) {
        tagsChanged = true
        sender.isSelected = !sender.isSelected
        if (sender.isSelected){
            leadAmountTextField.isEnabled = true
        }
        else{
            leadAmountTextField.isEnabled = false
        }
    }
    @IBAction func participateCheckBox(_ sender: UIButton) {
        tagsChanged = true
        sender.isSelected = !sender.isSelected
        if (sender.isSelected){
            participateAmountTextField.isEnabled = true
        }
        else{
            participateAmountTextField.isEnabled = false
        }
    }
    @IBAction func titleChanged(_ sender: UITextField) {
        titleChanged = true
    }
    @IBAction func descriptionChanged(_ sender: UITextField) {
        descriptionChanged = true
    }
    @IBAction func locationChanged(_ sender: UITextField) {
        locationChanged = true
    }
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss()
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
        if !(leadCheckBox.isSelected) && !(participateCheckBox.isSelected){
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToDetail"{
            handleTaskChange()
        }
    }
    
    private func handleTaskChange(){
        let valid = validate()
        if (valid){
            
            
            if (titleChanged || descriptionChanged || timeChanged || endTimeChanged || locationChanged || tagsChanged){
                let currentTask = Constants.refs.databaseTasks.child(task_in.id)
                if (titleChanged){
                    currentTask.child("taskTitle").setValue(titleTextField.text!)
                    
                }
                if (descriptionChanged){
                    currentTask.child("taskDescription").setValue(descriptionTextField.text!)
                }
                if (timeChanged){
                    currentTask.child("taskTime").setValue(timeTextField.text!)
                    currentTask.child("taskTimeMilliseconds").setValue(eventTime)
                }
                if (endTimeChanged){
                    currentTask.child("taskEndTime").setValue(endTimeTextField.text!)
                    currentTask.child("taskEndTimeMilliseconds").setValue(eventEndTime)
                }
                if (locationChanged){
                    currentTask.child("taskLocation").setValue(locationTextField.text!)
                }
                if (tagsChanged){
                    var amounts = Dictionary<String, Int>()
                    var tagResult: String = ""
                    var participantAmount = 0
                    var leaderAmount = 0
                    if leadCheckBox.isSelected {
                        leaderAmount = Int(leadAmountTextField.text!)!
                        if tagResult == ""{
                            tagResult.append("#lead")
                        }
                        else{
                            tagResult.append(" #lead")
                        }
                        amounts["leaders"] = leaderAmount
                    }
                    if participateCheckBox.isSelected {
                        participantAmount = Int(participateAmountTextField.text!)!
                        if tagResult == ""{
                            tagResult.append("#participate")
                        }
                        else{
                            tagResult.append(" #participate")
                        }
                        amounts["participants"] = participantAmount
                    }
                    currentTask.child("taskTag").setValue(tagResult)
                    currentTask.child("participantAmount").setValue(participantAmount)
                    currentTask.child("leaderAmount").setValue(leaderAmount)
                }
            }
        }
    }
}
