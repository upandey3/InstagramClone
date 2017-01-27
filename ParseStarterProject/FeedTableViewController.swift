//
//  FeedTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Utkarsh Pandey on 1/11/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse
class FeedTableViewController: UITableViewController {

    var users = [String: String]()
    var messages = [String]()
    var usernames = [String]()
    var imageFiles = [PFFile]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let query = PFUser.query()
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if error != nil {
            
                print ("Could not find users for FeedTableViewController")
                
            } else {
            
            
                if let users = objects {
                    
                    //clear the array to prevent loading twice
                    self.users.removeAll()
                
                    //gets the elements in objects array
                    for object in users{
                        
                        // if user can be cast as a PFUser
                        if let user  = object as? PFUser {
                            
                            //get the dictionary users for key - Id's, val  - username
                            self.users[user.objectId!] = user.username!
                        
                        }
                    }
                
                }
                
                let getFollowedUsersQuery = PFQuery(className: "Followers")
                
                // Get all the objects followed by the current user
                getFollowedUsersQuery.whereKey("follower", equalTo: (PFUser.current()?.objectId!)!)
    
                getFollowedUsersQuery.findObjectsInBackground(block: { (objects, error) in
                    
                    if error != nil {
                    
                        print ("Could not find followers")
                        
                    } else {
                        
                        if let followedUsers = objects {
                            
                            for object in followedUsers {
                                
                                //follower is the Follower class object where
                                //"follower" in current user
                                let follower = object
                                    
                                    let followedUser = follower["following"] as! String
                                    
                                    //Need a new query to get the images from Posts class
                                    let query = PFQuery(className: "Posts")
                                    
                                    //Getting query for the followed user
                                    query.whereKey("userid", equalTo: followedUser)
                                    
                                    query.findObjectsInBackground(block: { (objects, error) in
                                        if error != nil {
                                        
                                            print ("Could not find posts for the userid")
                                        
                                        } else {
                                            
                                            // get the posts that followed user
                                            if let posts = objects {
                                            
                                                for object in posts {
                                                
                                                    
                                                    if let image = object["imageFile"] as? PFFile {
                                                        
                                                      self.imageFiles.append(image)
                                                      self.messages.append(object["message"] as! String)
                                                      self.usernames.append(self.users[object["userid"] as! String]!)
                                                      self.tableView.reloadData()
                                                    }
                                                    
                                                }
                                            
                                            }
                                            
                                        }
                                        
                                    })
                                
                                
                            }
                            
                        }
                    
                    }
                })
 
            }
        })
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return imageFiles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedTableViewCell
        
        imageFiles[indexPath.row].getDataInBackground { (data, error) in
            
            if error != nil {
                print (error!)
            }else {
                
                if let imageData = data {
                
                    if let downloadedImage = UIImage(data: imageData) {
                        
                        cell.postedImage.image =  downloadedImage
                        
                    }
                }
                
            }
            
        }
        //cell.postedImage.image = UIImage(named: "person_icon.png")
        let name = usernames[indexPath.row].components(separatedBy: "@")
        
        cell.usernameLabel.text = name[0]
        
        cell.messageLabel.text = messages[indexPath.row]
        
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
