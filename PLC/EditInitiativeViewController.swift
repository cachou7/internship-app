//
//  EditInitiativeViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 7/11/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class EditInitiativeViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var validationButtonLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var leadAmountTextField: UITextField!
    @IBOutlet weak var leadCheckBox: UIButton!
    @IBOutlet weak var participateAmountTextField: UITextField!
    @IBOutlet weak var participateCheckBox: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var validationCheckBoxLabel: UILabel!
    @IBOutlet weak var bigIdeaButton: UIButton!
    @IBOutlet weak var communityButton: UIButton!
    
    //MARK: Variables
    let datePicker = UIDatePicker()
    var eventTime: TimeInterval = 0.0
    var task_in:Task!
    var task_out:Task!
    var titleChanged = false
    var descriptionChanged = false
    var timeChanged = false
    var locationChanged = false
    var tagsChanged = false
    var typeChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTask()
        
        validationCheckBoxLabel.isEnabled = false
        validationButtonLabel.isEnabled = false
        
        
        datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        timeTextField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePickerChanged), for:UIControlEvents.valueChanged)

        // Do any additional setup after loading the view.
    }
    
    private func configureTask(){
        titleTextField.text = task_in.title
        descriptionTextField.text = task_in.description
        timeTextField.text = task_in.time
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
        
        //TYPE BUTTONS
        switch(task_in.type){
            case "Big Idea" :
                bigIdeaButton.isSelected = true;
                communityButton.isSelected = false;
                bigIdeaButton.backgroundColor = UIColor.white
                break;
            case "Community" :
                communityButton.isSelected = true;
                bigIdeaButton.isSelected = false;
                communityButton.backgroundColor = UIColor.white
                break;
            default:
                bigIdeaButton.isSelected = false
                communityButton.isSelected = false
        }
        //END TYPE BUTTONS
        
        
        
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
    @IBAction func bigIdeaButton(_ sender: UIButton) {
        typeChanged = true
        communityButton.isSelected = false
        bigIdeaButton.isSelected = true
        bigIdeaButton.backgroundColor = UIColor.white
        communityButton.backgroundColor = UIColor.lightGray
    }
    @IBAction func communityButton(_ sender: UIButton) {
        typeChanged = true
        bigIdeaButton.isSelected = false
        communityButton.isSelected = true
        communityButton.backgroundColor = UIColor.white
        bigIdeaButton.backgroundColor = UIColor.lightGray
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
        timeChanged = true
        let dateFormatter = DateFormatter()
        eventTime = self.datePicker.date.timeIntervalSince1970
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
        if !(leadCheckBox.isSelected) && !(participateCheckBox.isSelected){
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToDetail"{
            handleTaskChange()
        }
    }
    
    private func handleTaskChange(){
        let valid = validate()
        if (valid){
            
            
            if (titleChanged || descriptionChanged || timeChanged || locationChanged || tagsChanged || typeChanged){
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
                if (typeChanged){
                    var type: String
                    if bigIdeaButton.isSelected {
                        type = "Big Idea"
                    }
                    else{
                        type = "Community"
                    }
                    currentTask.child("taskType").setValue(type)
                }
            }
        }
    }
}
