//
//  UserTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Utkarsh Pandey on 1/10/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {
    
    var usernames = [""]
    var userIDs = [""]
    var isFollowing = ["" : false]
    
    var refresher: UIRefreshControl!
    
    @IBAction func logout(_ sender: Any) {
        
        // The Logout button logs out the user using the parse server logOut() command
        // segues back into the login/signup screen
        PFUser.logOut()
        
        performSegue(withIdentifier: "logoutSegue", sender: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false

    }
    func refresh(){
        
        // The following happens when the instagram "users to follow display" is loaded for the currrent user
        let query = PFUser.query()
        
        // finding all the users
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if error != nil {
                
                print(error!)
            }
            else if let users = objects {
                
                //clearing all the storage arrays to refill them with the information relevant to the current user
                self.usernames.removeAll()
                self.userIDs.removeAll()
                self.isFollowing.removeAll()
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        // if the user is not the current user, to prevent the user following themselves.
                        if user.objectId != PFUser.current()?.objectId {
                            
                            // Storing the usernames and IDs in the array
                            let array = user.username!.components(separatedBy: "@")
                            self.usernames.append(array[0])
                            self.userIDs.append(user.objectId!)
                            
                            // Query for finding people that are being followed by the current user
                            let query = PFQuery(className: "Followers")
                            query.whereKey("follower", equalTo: (PFUser.current()?.objectId)!)
                            query.whereKey("following", equalTo: user.objectId!)
                            
                            query.findObjectsInBackground(block: { (objects, error) in
                                
                                if let objects = objects {
                                    
                                    // if the objects array is not empty, that means the current user is following
                                    // the user in the loop. So the isFollowing array is filled accordingly
                                    if objects.count > 0 {
                                        
                                        self.isFollowing[user.objectId!] = true
                                        
                                    } else {
                                        
                                        self.isFollowing[user.objectId!] = false
                                        
                                    }
                                    // if all the usernames have been assessed for "following", then reload the table data
                                    if self.isFollowing.count == self.usernames.count{
                                        
                                        self.tableView.reloadData()
                                        
                                        self.refresher.endRefreshing()
                                    }
                                }
                                
                                
                            })
                            
                        }
                    }
                    
                }
            }
            
        })
    
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        refresh()
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refresher.addTarget(self, action: #selector(UserTableViewController.refresh), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refresher)
        
        

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
        return usernames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //This is for filling up the users to follow display
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Fill cells with usernames array
        cell.textLabel?.text = usernames[indexPath.row]
        
        // All the cells representing people being followed the current user are represented with a "checkmark"
        if isFollowing[userIDs[indexPath.row]]! {
        
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // What happens when a cell(person) is selected in the users to follow display
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if isFollowing[userIDs[indexPath.row]]! {
            //if the cell(person) is checkmarked or is being followed already, unfollow that person
            
            cell?.accessoryType = UITableViewCellAccessoryType.none // uncheck it
            isFollowing[userIDs[indexPath.row]] = false             // update the isFollowing array
            let query = PFQuery(className: "Followers")
            
            //find that association in the Followers class on the parse server and delete it
            query.whereKey("follower", equalTo: (PFUser.current()?.objectId)!)
            query.whereKey("following", equalTo: userIDs[indexPath.row])

            query.findObjectsInBackground(block: { (objects, error ) in
                
                if let objects = objects {
                
                    for object in objects {
                    
                        object.deleteInBackground()
                    
                    }
                }
            })
            
            
        } else { // if the cell is not checkmarked, follow that person
            //Check the cell (indicate that now they are being followed by the user)
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            
            isFollowing[userIDs[indexPath.row]] = true             // update the isFollowing array

            // Update the Followers class on Parse server
            let following = PFObject(className: "Followers")
            following["follower"] = PFUser.current()?.objectId
            following["following"] = userIDs[indexPath.row]
            following.saveInBackground()
            
        }
        
        
    }

 
}
