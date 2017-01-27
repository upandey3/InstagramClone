//
//  PostViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Utkarsh Pandey on 1/10/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var imagePicked = false
    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    var activityind = UIActivityIndicatorView()
 
    @IBAction func chooseImage(_ sender: Any) {
    
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated:true, completion: nil)
        
    
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageToPost.image = image
            imagePicked = true
        
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func createAlert(title: String, message :String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {
            (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        })) 
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func postImage(_ sender: Any) {
        
        if !imagePicked {
            
            createAlert(title: "No image to post!", message: "Please choose an image first")
            
        }
        else {
            activityind = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityind.center = self.view.center
            activityind.hidesWhenStopped = true
            activityind.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            activityind.startAnimating()
            view.addSubview(activityind)
            UIApplication.shared.beginIgnoringInteractionEvents()

        
            let post = PFObject(className: "Posts")
        
            post["message"] = captionField.text
        
            post["userid"] = PFUser.current()?.objectId!
        
            let imageData = UIImageJPEGRepresentation(imageToPost.image!, 0.5) //UIImagePNGRepresentation(imageToPost.image!)
        
            let imageFile = PFFile(name: "image.png", data: imageData!)
        
            post["imageFile"] = imageFile
        
            post.saveInBackground { (success, error) in
            
                self.activityind.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            
                if error != nil {
                
                    self.createAlert(title: "Oops! Something went wrong.", message: "Unable to post image. Please try again later.")
            
                } else {
            
                    self.createAlert(title: "Success!", message: "Your image has been posted! ")
                    self.imageToPost.image = UIImage(named: "person_icon.png")
                    
                    self.captionField.text = ""
                    
                    self.imagePicked = false
                
                }
            
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
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
