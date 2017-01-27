/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    var signupMode = true
    
    var activityind = UIActivityIndicatorView()
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func createAlert(title: String, message :String){
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {
            (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)

    
    }
    
    @IBAction func signupOrLogin(_ sender: Any) {
    
        if emailText.text == "" || passwordText.text == ""{
        
            createAlert(title: "Error in form", message: "Please enter an email and password")
            
            
        } else {
            
            activityind = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityind.center = self.view.center
            activityind.hidesWhenStopped = true
            activityind.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            activityind.startAnimating()
            view.addSubview(activityind)
            UIApplication.shared.beginIgnoringInteractionEvents()
            
        
            if signupMode{
                //Sign Up
             
                let user = PFUser()
                
                user.username = emailText.text
                user.email = emailText.text
                user.password = passwordText.text
                
                user.signUpInBackground(block: { (success, error) in
                    
                    self.activityind.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                
                    if error != nil {
                    
                        var displayErrorMessage = "Something went wrong. Please try again later."
                        if let errorMessage = (error! as NSError).userInfo["error"] as? String {
                            
                            displayErrorMessage = errorMessage
                        
                        }
                        self.createAlert(title: "Error in form", message: displayErrorMessage)
                    }else {
                    
                        print("user signed up")
                        
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                    
                    
                })
                
                
            } else {
            
                //Login mode
                
                PFUser.logInWithUsername(inBackground: emailText.text!, password: passwordText.text!, block: { (user, error) in
                    
                    self.activityind.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if error != nil {
                        
                        var displayErrorMessage = "Something went wrong. Please try again later."
                        if let errorMessage = (error! as NSError).userInfo["error"] as? String {
                             
                            displayErrorMessage = errorMessage
                            
                        }
                        self.createAlert(title: "Error in form", message: displayErrorMessage)
                    }else {
                        
                        print("Logged In")
                        
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                    
                })
                
            }
            
            
            
        
        }
        
    }
    @IBOutlet weak var signupOrLoginButton: UIButton!
    
    @IBAction func changeSignupMode(_ sender: Any) {
        
        if signupMode {
        
            //Change to login mode
            
            signupMode = false
            
            signupOrLoginButton.setTitle("Log In", for: [])
        
            changeSignupModeButton.setTitle("Sign Up", for: [])
            
            messageLabel.text = "Don't have an account?"
            
        } else {
        
            signupMode = true
            
            signupOrLoginButton.setTitle("Sign Up", for: [])
            
            changeSignupModeButton.setTitle("Log In", for: [])
            
            messageLabel.text = "Already have an account?"
            
        }
    
    }
    
    @IBOutlet weak var changeSignupModeButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current() != nil {
        
            performSegue(withIdentifier: "showUserTable", sender: self)
            
        }
        
        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidLoad() {
    
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
