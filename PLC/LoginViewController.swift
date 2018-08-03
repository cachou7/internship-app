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
        
        presenter.roundCorners = true
        presenter.cornerRadius = 20
        
        textFieldLoginEmail.borderStyle = UITextBorderStyle.none
        textFieldLoginPassword.borderStyle = UITextBorderStyle.none
        textFieldLoginEmail.layer.borderWidth = 0
        textFieldLoginPassword.layer.borderWidth = 0
        textFieldLoginEmail.layer.cornerRadius = 15.0
        textFieldLoginEmail.layer.borderWidth = 2.0
        textFieldLoginPassword.layer.cornerRadius = 15.0
        textFieldLoginPassword.layer.borderWidth = 2.0
        
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
        
        // set frame on image before adding it to the uitextfield
        imageViewPassword.image = imagePassword;
        imageViewPassword.frame = CGRect(x: 10, y: 9, width: iconWidth, height: iconHeight)
        textFieldLoginPassword.leftViewMode = UITextFieldViewMode.always
        textFieldLoginPassword.addSubview(imageViewPassword)
        
        //set Padding
        let paddingView = UIView(frame: CGRect(x: 5, y: 5, width: 45, height: 45))
        textFieldLoginEmail.leftView = paddingView
        
        let emailPaddingView = UIView(frame: CGRect(x: 25, y: 25, width: 40, height: self.textFieldLoginPassword.frame.height))
        textFieldLoginPassword.leftView = emailPaddingView
        
        
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
                            uidSnapshot.childSnapshot(forPath: "firstName").value as! String, lastName: uidSnapshot.childSnapshot(forPath: "lastName").value as! String, jobTitle: uidSnapshot.childSnapshot(forPath: "jobTitle").value as! String, department: uidSnapshot.childSnapshot(forPath: "department").value as! String, funFact: uidSnapshot.childSnapshot(forPath: "funFact").value as! String, points: uidSnapshot.childSnapshot(forPath: "points").value as! Int)
                        
                    }
                })
                
                let deadlineTime = DispatchTime.now() + .seconds(3)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.performSegue(withIdentifier: self.loginToTasks, sender: nil)
                    self.textFieldLoginEmail.text = nil
                    self.textFieldLoginPassword.text = nil
                }
            }
        }
    }
    
    @IBAction func signUpDidTouch(_ sender: Any) {
        CreateNewAccountController = (storyboard?.instantiateViewController(withIdentifier: "CreateNewAccountViewController") as! CreateNewAccountViewController)
        customPresentViewController(presenter, viewController: CreateNewAccountController!, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToLogin(segue:UIStoryboardSegue){
        currentUser = nil
    }
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

