//
//  InitiativeCreateViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 6/27/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class InitiativeCreateViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var participateCheck: UIButton!
    @IBOutlet weak var leadCheck: UIButton!
    @IBOutlet weak var createCheck: UIButton!
    @IBOutlet weak var timeTextField: UITextField!
    
    let datePicker = UIDatePicker()
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        timeTextField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePickerChanged), for:UIControlEvents.valueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func leadCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func participateCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    @IBAction func createButton(_ sender: UIBarButtonItem) {
        var tagResult: String = ""
        if leadCheck.isSelected {
            if tagResult == ""{
                tagResult.append("#lead")
            }
            else{
                tagResult.append(" #lead")
            }
        }
        if createCheck.isSelected {
            if tagResult == ""{
                tagResult.append("#create")
            }
            else{
                tagResult.append(" #create")
            }
        }
        if participateCheck.isSelected {
            if tagResult == ""{
                tagResult.append("#participate")
            }
            else{
                tagResult.append(" #participate")
            }
        }
        let interval = NSDate().timeIntervalSince1970
        let key = Constants.refs.databaseTasks.childByAutoId().key
        
        task = Task(title: titleTextField.text!, description: descriptionTextField.text!, tag: tagResult, time: timeTextField.text!, location: locationTextField.text!, timestamp: String(interval), id: key, createdBy: currentUser.uid)
        
        let taskDB = ["taskId": key, "taskTitle": task?.title, "taskDescription": task?.description, "taskTag": task?.tag, "taskTime": task?.time, "taskLocation": task?.location, "timestamp": task?.timestamp, "createdBy" : task?.createdBy]
        Constants.refs.databaseTasks.child(key).setValue(taskDB)
        let tasksCreated = Constants.refs.databaseUsers.child(currentUser.uid + "/tasks_created")
        tasksCreated.child("taskId").setValue(key)
        print("Task added")
        dismiss()
    }
    
    @objc func datePickerChanged(datePicker:UIDatePicker) {
        print("time picker changed for ceremony")
        let dateFormatter = DateFormatter()
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
    
    
}
