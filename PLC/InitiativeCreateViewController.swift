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
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    let datePicker = UIDatePicker()
    
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        timeTextField.inputView = datePicker
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), for:UIControlEvents.valueChanged)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    @IBAction func createButton(_ sender: UIBarButtonItem) {
        task = Task(title: titleTextField.text!, description: descriptionTextField.text!, tag: tagTextField.text!, time: timeTextField.text!, location: locationTextField.text!)
        let key = Constants.refs.databaseTasks.childByAutoId().key
        let taskDB = ["taskId": key, "taskTitle": task?.title, "taskDescription": task?.description, "taskTag": task?.tag, "taskTime": task?.time, "taskLocation": task?.location]
        Constants.refs.databaseTasks.child(key).setValue(taskDB)
        print("Task added")
        dismiss()
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
        print("time picker changed for ceremony")
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
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
