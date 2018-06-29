//
//  InitiativeCreateViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 6/27/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class InitiativeCreateViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tagPickerData.count
    }
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tagPickerData[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tagTextField.text = tagPickerData[row]
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    let datePicker = UIDatePicker()
    let tagPicker = UIPickerView()
    let tagPickerData = ["#create", "#participate", "#lead"]
    
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagTextField.inputView = tagPicker
        datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        timeTextField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePickerChanged), for:UIControlEvents.valueChanged)
        // Do any additional setup after loading the view.
        tagPicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    @IBAction func createButton(_ sender: UIBarButtonItem) {
        let interval = NSDate().timeIntervalSince1970
        task = Task(title: titleTextField.text!, description: descriptionTextField.text!, tag: tagTextField.text!, time: timeTextField.text!, location: locationTextField.text!, timestamp: String(interval))
        
        let key = Constants.refs.databaseTasks.childByAutoId().key
        let taskDB = ["taskId": key, "taskTitle": task?.title, "taskDescription": task?.description, "taskTag": task?.tag, "taskTime": task?.time, "taskLocation": task?.location, "timestamp": task?.timestamp]
        Constants.refs.databaseTasks.child(key).setValue(taskDB)
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
