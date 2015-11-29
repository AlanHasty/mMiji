//
//  WorkoutsViewController.swift
//  mMiji
//
//  Created by Alan Hasty on 11/3/15.
//  Copyright © 2015 Alan Hasty. All rights reserved.
//

import UIKit

class WorkoutsViewController: UITableViewController {

    var workoutList: [String] = []
    let workoutCell = "WorkoutCell"
    var tonightsWorkout = 999
    var tonightsWorkoutStr: String = "Nothing Selected"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        listFilesFromDocumentsFolder()
        
    }
    
    func listFilesFromDocumentsFolder()
    {

        let fm = NSFileManager.defaultManager()
        let path = NSBundle.mainBundle().resourcePath!
 
        do {
            let dirContents = try fm.contentsOfDirectoryAtPath(path)
            workoutList = dirContents.filter() {$0.containsString("json")}
        }
        catch {
            print("This is a bad path \(path)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return workoutList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(workoutCell, forIndexPath: indexPath)

        // Configure the cell...
        let row = indexPath.row
        
        cell.textLabel?.text = workoutList[row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var wkoutString:String = workoutList[indexPath.row]
        let removeRange = wkoutString.endIndex.advancedBy(-5)..<wkoutString.endIndex
        
        
        wkoutString.removeRange(removeRange)
        tonightsWorkoutStr = wkoutString
        wkoutString.removeAtIndex(wkoutString.startIndex)
        if let wkselection = Int(wkoutString) {
            tonightsWorkout = wkselection
        }
        
//        let alertController = UIAlertController(title: "Workout Selction", message: "Workout \(tonightsWorkoutStr) selected", preferredStyle: .Alert)
//          alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil ))
//          presentViewController(alertController, animated: true, completion: nil)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "trainingSheet"
        {
            let nav = segue.destinationViewController
            
            let vc =   nav.childViewControllers[0]  as! TrainingViewController
            vc.tonightsWorkout = tonightsWorkout
            vc.tonightsWorkoutStr = tonightsWorkoutStr
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == "trainingSheet" {
            
            if tonightsWorkout == 999 {
                // put up modal - Make a selection
                let alertController = UIAlertController(title: "Workout Selction", message: "No Workout selected", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil ))
                presentViewController(alertController, animated: true, completion: nil)
                
                return false
            }
            return true
        }
        return false
    }
    

}
