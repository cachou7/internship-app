//
//  LoginViewController.swift
//  PLC
//
//  Created by Chris on 6/29/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import FirebaseAuth
import Presentr

var currentUser: User!

class LoginViewController: UIViewController {
    
    // MARK: Constants
    let loginToTasks = "LoginToTasks"
    
    var presenter = Presentr(presentationType: .popup)
    var CreateNewAccountController : CreateNewAccountViewController?
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sign-up appearance
        presenter.roundCorners = true
        presenter.cornerRadius = 20
        
        // Text fields appearance
        textFieldLoginEmail.borderStyle = UITextBorderStyle.none
        textFieldLoginPassword.borderStyle = UITextBorderStyle.none
        textFieldLoginEmail.layer.borderWidth = 0
        textFieldLoginPassword.layer.borderWidth = 0
        textFieldLoginEmail.layer.cornerRadius = 15.0
        textFieldLoginEmail.layer.borderWidth = 2.0
        textFieldLoginPassword.layer.cornerRadius = 15.0
        textFieldLoginPassword.layer.borderWidth = 2.0
        
        // Email and password icons and appearance
        let iconWidth = 25
        let iconHeight = 25
        
        let imageView = UIImageView()
        let imageEmail = UIImage(named: "iconEmail")
        imageView.image = imageEmail
        imageView.contentMode = .scaleAspectFit
        
        imageView.frame = CGRect(x: 10, y: 9, width: iconWidth, height: iconHeight)
        textFieldLoginEmail.leftViewMode = UITextFieldViewMode.always
        textFieldLoginEmail.addSubview(imageView)
        
        let imageViewPassword = UIImageView();
        let imagePassword = UIImage(named: "iconLock");
        
        // Set frame on image before adding it to the UITextField
        imageViewPassword.image = imagePassword;
        imageViewPassword.frame = CGRect(x: 10, y: 9, width: iconWidth, height: iconHeight)
        textFieldLoginPassword.leftViewMode = UITextFieldViewMode.always
        textFieldLoginPassword.addSubview(imageViewPassword)
        
        // Set Padding
        let paddingView = UIView(frame: CGRect(x: 5, y: 5, width: 45, height: 45))
        textFieldLoginEmail.leftView = paddingView
        
        let emailPaddingView = UIView(frame: CGRect(x: 25, y: 25, width: 40, height: self.textFieldLoginPassword.frame.height))
        textFieldLoginPassword.leftView = emailPaddingView
        
        
        // Create authentication observer if user authentication is successful
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // Clear text field text
                self.textFieldLoginEmail.text = nil
                self.textFieldLoginPassword.text = nil
            }
        }
    }
    
    // If user clicks on Login button
    @IBAction func loginDidTouch(_ sender: Any) {
        
        // Guard
        guard
            let email = textFieldLoginEmail.text,
            let password = textFieldLoginPassword.text,
            email.count > 0,
            password.count > 0
            else { return }
        
        // Sign in with Firebase
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            
            // Sign in failed
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Sign In Failed", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            // Sign in successful
            else {
                // Guard
                guard let user = Auth.auth().currentUser else { return }
                // Get user info from database
                Constants.refs.databaseUsers.observe(.value, with: { snapshot in
                    if snapshot.hasChild(user.uid) {
                        let uidSnapshot = snapshot.childSnapshot(forPath: user.uid)
                        
                        currentUser = User(authData: user, firstName:
                            uidSnapshot.childSnapshot(forPath: "firstName").value as! String, lastName: uidSnapshot.childSnapshot(forPath: "lastName").value as! String, jobTitle: uidSnapshot.childSnapshot(forPath: "jobTitle").value as! String, department: uidSnapshot.childSnapshot(forPath: "department").value as! String, funFact: uidSnapshot.childSnapshot(forPath: "funFact").value as! String, points: uidSnapshot.childSnapshot(forPath: "points").value as! Int)
                        
                    }
                })
                
                // Async load after login
                let deadlineTime = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.performSegue(withIdentifier: self.loginToTasks, sender: nil)
                    self.textFieldLoginEmail.text = nil
                    self.textFieldLoginPassword.text = nil
                }
            }
        }
    }
    
    // User clicks sign up button
    @IBAction func signUpDidTouch(_ sender: Any) {
        CreateNewAccountController = (storyboard?.instantiateViewController(withIdentifier: "CreateNewAccountViewController") as! CreateNewAccountViewController)
        customPresentViewController(presenter, viewController: CreateNewAccountController!, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Logout
    @IBAction func unwindToLogin(segue:UIStoryboardSegue){
        currentUser = nil
    }
}

// Set up UITextField responders
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

