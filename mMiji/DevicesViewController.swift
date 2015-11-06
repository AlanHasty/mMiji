//
//  DevicesViewController.swift
//  mMiji
//
//  Created by Alan Hasty on 11/4/15.
//  Copyright © 2015 Alan Hasty. All rights reserved.
//

import UIKit

class DevicesViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    var cscDevices: [CSCDevice] = cscData
    let cscCellID = "CSCDeivceCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //tableView.delegate = self
        //tableView.dataSource = self
        
        tableView.registerClass(CSCDeviceCell.self, forCellReuseIdentifier: cscCellID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cscDevices.count
    }
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cscCellID, forIndexPath: indexPath) as! CSCDeviceCell
//        let cell = tableView.dequeueReusableCellWithIdentifier(cscCellID, forIndexPath: indexPath)
        
        let row = indexPath.row
        let device = cscDevices[row]
        
        cell.textLabel?.text = device.macAddress
//
//        cell.name.text = device.name
//        cell.status.text = device.status
//        cell.macAddress.text = device.macAddress
        
        //cell?.textLabel!.text = cscDevices[row].name
        //cell?.detailTextLabel!.text = cscDevices[row].macAddress
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
