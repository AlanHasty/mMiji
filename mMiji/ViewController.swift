//
//  ViewController.swift
//  mMiji
//
//  Created by Alan Hasty on 10/23/15.
//  Copyright © 2015 Alan Hasty. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    var cscDevices: [CSCDevice] = cscData
    let cscDeviceCell = "CSCDeivceCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cscDeviceCell, forIndexPath: indexPath) as! CSCDeviceCell
        
        let row = indexPath.row
        let device = cscDevices[row]
        
        cell.name.text = device.name
        cell.status.text = device.status
        cell.macAddress.text = device.macAddress
        
        //cell?.textLabel!.text = cscDevices[row].name
        //cell?.detailTextLabel!.text = cscDevices[row].macAddress
        
        return cell
    }

}

