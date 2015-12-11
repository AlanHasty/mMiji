//
//  DevicesViewController.swift
//  mMiji
//
//  Created by Alan Hasty on 11/4/15.
//  Copyright © 2015 Alan Hasty. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreBluetooth

var cscDevices: [CSCDevice] = cscData
var pairedRiderIndex: Int = 0;

class DevicesViewController: UIViewController,
                             UITableViewDataSource,
                             UITableViewDelegate,
                             CBCentralManagerDelegate,
                             CBPeripheralDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var labelStatus: UILabel!
    
    // BLE Stuff
    var myCentralManager = CBCentralManager()
    var peripheralArray = [CBPeripheral]() // create now empty array.
    
    var scanningState: Bool = false
    var prevCrankEvt: UInt32 = 0
    var prevWheelEvt: UInt32 = 0
    var prevWheelRev: UInt32 = 0
    var prevCrankRev: UInt32 = 0
    

    
    @IBOutlet weak var scanButton: UIButton!
    @IBAction func scanForDevices(sender: AnyObject) {

        if scanningState == false
        {
            myCentralManager.scanForPeripheralsWithServices(nil, options: nil )   // call to scan for services
            printToMyTextView("\r scanning for Peripherals")
            scanningState = true
            scanButton.titleLabel?.text = "Stop Scanning"
            
        }
        else
        {
            myCentralManager.stopScan()   // stop scanning to save power
            scanningState = false
            printToMyTextView("stop scanning")
            scanButton.titleLabel?.text = "Scan for devices"
            if (peripheralArray.count > 0 ) {
                myCentralManager.cancelPeripheralConnection(peripheralArray[0])
            }
        }
    }
    
    
    
    let cscCellID = "CSCDeivceCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())


        // Do any additional setup after loading the view.
        //tableView.delegate = self
        //tableView.dataSource = self
        
        //tableView.registerClass(CSCDeviceCell.self, forCellReuseIdentifier: cscCellID)
    }
    
//    // Put CentralManager in the main queue
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        labelStatus.text = "None found"
//        myCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
//        
//    }
    

    // Mark   CBCentralManager Methods
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        updateStatusLabel("centralManagerDidUpdateState")
        
        /*
        typedef enum {
        CBCentralManagerStateUnknown  = 0,
        CBCentralManagerStateResetting ,
        CBCentralManagerStateUnsupported ,
        CBCentralManagerStateUnauthorized ,
        CBCentralManagerStatePoweredOff ,
        CBCentralManagerStatePoweredOn ,
        } CBCentralManagerState;
        */
        switch central.state{
        case .PoweredOn:
            updateStatusLabel("poweredOn")
            
            
        case .PoweredOff:
            updateStatusLabel("Central State PoweredOFF")
            
        case .Resetting:
            updateStatusLabel("Central State Resetting")
            
        case .Unauthorized:
            updateStatusLabel("Central State Unauthorized")
            
        case .Unknown:
            updateStatusLabel("Central State Unknown")
            
        case .Unsupported:
            updateStatusLabel("Central State Unsupported")
            
        default:
            updateStatusLabel("Central State None Of The Above")
            
        }
        
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        updateStatusLabel(" - didDiscoverPeripheral - ")
        
        //        if RSSI.intValue > -100 ||
        if   peripheral.name != nil {  // Look for your device by Name
            
            printToMyTextView("Description: \(peripheral.identifier.UUIDString)")
            printToMyTextView("Services: \(advertisementData)")
            printToMyTextView("RSSI: \(RSSI)")
            printToMyTextView("Name: \(peripheral.name)")
            printToMyTextView("\r")
            
        }
        
        
        //        if peripheral?.name == "RedYoda"{  // Look for your device by Name
        
        if (advertisementData[CBAdvertisementDataLocalNameKey] != nil) {
//            myCentralManager.stopScan()  // stop scanning to save power
//            print("myCentralManager.stopScan()")
            
            peripheralArray.append(peripheral) // add found device to device array to keep a strong reverence to it.
            updateStatusLabel("peripheralArray.append(peripheral)")
            
            myCentralManager.connectPeripheral(peripheralArray[0], options: nil)  // connect to this found device
//            updateStatusLabel("myCentralManager.connectPeripheral(peripheralArray[0]")
//            printToMyTextView("Attempting to Connect to \(peripheral.name)  \r")
            
            
            
            // Need to check if we have seen this sensor already.
            // And only add it IF it's not already in the list.
            var found: Bool = false
            for dev in cscDevices
            {
                if dev.name == peripheral.name { found = true; break;}
            }
            if found == false
            {
                let uuidDevice = peripheral.identifier.UUIDString
                
                var newSensor = CSCDevice(name:peripheral.name, macAddress:uuidDevice, paired:true)
                cscDevices += [newSensor]
            }
            
            tableView.reloadData()
            
        }
    }
    
    func peripheralDidUpdateName(peripheral: CBPeripheral) {
        printToMyTextView("** peripheralDidUpdateName **")
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        printToMyTextView("\r\r Did Connect to \(peripheral.name) \r\r")
        peripheral.delegate = self
        peripheral.discoverServices(nil)  // discover services
        printToMyTextView("Scanning For Services")
        
        labelStatus.text = peripheral.name
        for ( loop, var rider) in cscDevices.enumerate()
        {
            if rider.name == peripheral.name
            {
                rider.paired = true
                pairedRiderIndex = loop
                break
            }
        }
        
        //  peripheralArray.append(peripheral)
        
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        labelStatus.text = "didDisconnectPeripheral"
    }
    
    // Mark   CBPeriperhalManager
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        updateStatusLabel("\r\r Discovered Services for \(peripheral.name) \r\r")
        printToMyTextView("\r\r Discovered Services for \(peripheral.name) \r\r")
        
        for service in peripheral.services! as [CBService]{
            printToMyTextView("Service.UUID \(service.UUID) Service.UUID.UUIDString \(service.UUID.UUIDString)"  )
            
            if CSCTag.validService(service) {
                // Discover characteristics of all valid services
                peripheral.discoverCharacteristics(nil, forService: service)
            }
            
            
            //            if service.UUID.UUIDString == "180F"{
            //                printToMyTextView("------ FOUND BATT service.")
            //                peripheral.discoverCharacteristics(nil, forService: service)
            //            }
            //
            //            if service.UUID.UUIDString == "1816" {
            //                printToMyTextView("____ Found Cycling Speed and Cadence\r")
            //                peripheral.discoverCharacteristics(nil, forService: service)
            //            }
        }
    }
    
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        var enableValue = 1
        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
        printToMyTextView("DidDiscoverCharacteristicsForService:  Service.UUID \(service.UUID)  UUIDString \(service.UUID.UUIDString)\r")
        printToMyTextView("Enabling sensors")
        
        for characteristic in service.characteristics! as [CBCharacteristic]{
            
            //peripheral.readValueForCharacteristic(characteristic)
            printToMyTextView("\(characteristic)")
            if CSCTag.validDataCharacteristic(characteristic)
            {
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
    }
    
    
    
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        
        print("readRSSI")
    }
    
    func peripheralDidUpdateRSSI(peripheral: CBPeripheral, error: NSError?) {
        print("didUpdateRSSI")
    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        printToMyTextView("  Read Char Property:Value: \(characteristic.properties):\(characteristic.value)\r")
        
        //        var myData = NSData()
        //        if let foo = characteristic.value {
        //            myData = characteristic.value
        //            printToMyTextView("MyData: \(myData)")
        //        }
        
        //     return [WheelRev, WheelEvt, CrankRev, CrankEvt]
        
        
        if characteristic.UUID == CSCMeasurementDataUUID
        {
            var wheelData : [UInt32] = CSCTag.getCSCData(characteristic.value!)
            
            var wheelRev = wheelData[0]
            var wheelEvt = wheelData[1]
            var crankRev = wheelData[2]
            var crankEvt = wheelData[3]
            
            print("Wheel Event \(wheelEvt) ms : Crank Event \(crankEvt) ms")
            print("Wheel Revs \(wheelRev) : Crank Revs \(crankRev)")
            
            if crankEvt < prevCrankEvt
            {
                crankEvt += 65535
            }
            let crankPeriod = crankEvt - prevCrankEvt
            var crevs :UInt32
            if crankPeriod > 0 {
                crevs = (crankRev - prevCrankRev) * 60000 / crankPeriod
            }
            else {
                crevs = 0
            }
            
            
            if wheelEvt < prevWheelEvt
            {
                wheelEvt += 65535
            }
            
            let wheelPeriod = wheelEvt - prevWheelEvt
            var wrevs : UInt32 = 0
            
            if wheelPeriod > 0
            {
                wrevs = ((wheelRev - prevWheelRev) * 60000)/wheelPeriod
            }
            else
            {
                wrevs = 0
            }
            
//            if wrevs > 300 {wheelRevs.text = "Wooh"}
//            else { wheelRevs.text = "\(wrevs)"}
//            
//            if crevs > 300 { crankRevs.text = "Woow"}
//            else { crankRevs.text = "\(crevs)" }
//            println("Cadence: \(crevs) rpm \tWheel: \(wrevs) rpm")
            
            prevCrankRev = crankRev
            prevWheelRev = wheelRev
            prevCrankEvt = crankEvt
            prevWheelEvt = wheelEvt
            
            cscDevices[pairedRiderIndex].wheelRevs = Int(wrevs)
            
            print("Wheel Revs update:\(wrevs)\r")
            
        }
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
        
        cell.device = device  //
//        cell.name.text = device.name
//        cell.status.text = device.status
//
        
        
        //cell.macAddress.text = device.macAddress
        
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
    func printToMyTextView(passedString: String){
        print("\(passedString)\r")
        //myTextView.text = passedString + "\r" + myTextView.text
    }
    func updateStatusLabel(passedString: String){
        labelStatus.text = passedString
    }
}
