//
//  LoginViewController.swift
//  PLC
//
//  Created by Chris on 6/29/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import FirebaseAuth

var currentUser: User!

class LoginViewController: UIViewController {
    
    // MARK: Constants
    let loginToTasks = "LoginToTasks"
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create authentication observer if user authentication is successful
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // Clear text field text
                //self.performSegue(withIdentifier: self.loginToTasks, sender: nil)
                self.textFieldLoginEmail.text = nil
                self.textFieldLoginPassword.text = nil
            }
        }
    }

    @IBAction func loginDidTouch(_ sender: Any) {
        guard
            let email = textFieldLoginEmail.text,
            let password = textFieldLoginPassword.text,
            email.count > 0,
            password.count > 0
            else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            print(user == nil)
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Sign In Failed", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true, completion: nil)
            }
            else{
                guard let user = Auth.auth().currentUser else { return }
                Constants.refs.databaseUsers.observe(.value, with: { snapshot in
                    if snapshot.hasChild(user.uid) {
                        print("User already in database")
                        print(user.uid)
                        let uidSnapshot = snapshot.childSnapshot(forPath: user.uid)
                        
                        currentUser = User(authData: user, firstName:
                            uidSnapshot.childSnapshot(forPath: "firstName").value as! String, lastName: uidSnapshot.childSnapshot(forPath: "lastName").value as! String, jobTitle: uidSnapshot.childSnapshot(forPath: "jobTitle").value as! String, department: uidSnapshot.childSnapshot(forPath: "department").value as! String, currentProjects: uidSnapshot.childSnapshot(forPath: "currentProjects").value as! String)
                        
                    }
                })
                self.performSegue(withIdentifier: self.loginToTasks, sender: nil)
                self.textFieldLoginEmail.text = nil
                self.textFieldLoginPassword.text = nil
            }
        }
    }
    
    @IBAction func signUpDidTouch(_ sender: Any) {
        let alert = UIAlertController(title: "Register",
                                      message: "",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            let firstName = alert.textFields![2].text
            let lastName = alert.textFields![3].text
            let jobTitle = alert.textFields![4].text
            let department = alert.textFields![5].text
            let projects = alert.textFields![6].text
            
            // Creates a new user account if there are no errors
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
                if error == nil {
                        guard let user = Auth.auth().currentUser else { return }
                        currentUser = User(authData: user, firstName: firstName!, lastName: lastName!, jobTitle: jobTitle!, department: department!, currentProjects: projects!)
                        let key = currentUser.uid
                        Constants.refs.databaseUsers.observe(.value, with: { snapshot in
                            if !snapshot.hasChild(key) {
                                print("New user added to database")
                                Constants.refs.databaseUsers.child(key).setValue(["uid": key, "firstName": firstName!, "lastName": lastName!, "jobTitle": jobTitle!, "department": department!, "currentProjects": projects!, "tasks_created": [], "tasks_liked": []])
                            }
                        })
                    Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
                                       password: self.textFieldLoginPassword.text!)
                    self.performSegue(withIdentifier: self.loginToTasks, sender: nil)
                    self.textFieldLoginEmail.text = nil
                    self.textFieldLoginPassword.text = nil
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addTextField { textFirstName in
            textFirstName.placeholder = "First Name"
        }
        
        alert.addTextField { textLastName in
            textLastName.placeholder = "Last Name"
        }
        
        alert.addTextField { textJobTitle in
            textJobTitle.placeholder = "Job Title"
        }
        
        alert.addTextField { textDepartment in
            textDepartment.placeholder = "Department"
        }
        
        alert.addTextField { textProjects in
            textProjects.placeholder = "Current Projects"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
        }
        return true
    }
}

