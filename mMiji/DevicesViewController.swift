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

var cscDevices = [CSCDevice]()
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

    var firstTime: Bool = true;
    
    @IBOutlet weak var scanBtnText: UIButton!
    @IBAction func scanForDevices(sender: AnyObject) {

        if scanningState == false
        {
            myCentralManager.scanForPeripheralsWithServices(nil, options: nil )   // call to scan for services
            scanningState = true
            scanBtnText.setTitle("Stop Scanning", forState: UIControlState.Normal)
        }
        else
        {
            myCentralManager.stopScan()   // stop scanning to save power
            scanningState = false
            scanBtnText.setTitle("Scan", forState: UIControlState.Normal)

//            if (peripheralArray.count > 0 ) {
//                myCentralManager.cancelPeripheralConnection(peripheralArray[0])
//            }
        }
    }
    
    let cscCellID = "CSCDeivceCell"
    
    @IBAction func ConnectDevice(sender: AnyObject) {
        let sensor = cscDevices[pairedRiderIndex]
        myCentralManager.connectPeripheral(peripheralArray[pairedRiderIndex], options: nil)
        printToMyTextView("Trying device: \(sensor.uid)\r")
        // Stop scanning if you are going to connect
        let falseButton = UIButton()
        scanForDevices(falseButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())

    }

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
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral,
                        advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        updateStatusLabel(" - didDiscoverPeripheral - ")
        
        //        if RSSI.intValue > -100 ||
        if   peripheral.name != nil {  // Look for your device by Name
            
            printToMyTextView("Description: \(peripheral.identifier.UUIDString)")
            printToMyTextView("Services: \(advertisementData)")
            printToMyTextView("RSSI: \(RSSI)")
            printToMyTextView("Name: \(peripheral.name)")
            printToMyTextView("\r")
            
        }
        
        if (advertisementData[CBAdvertisementDataLocalNameKey] != nil) {

            //            myCentralManager.stopScan()  // stop scanning to save power
//            print("myCentralManager.stopScan()")
//            myCentralManager.connectPeripheral(peripheralArray[0], options: nil)  // connect to this found device
//            updateStatusLabel("myCentralManager.connectPeripheral(peripheralArray[0]")
//            printToMyTextView("Attempting to Connect to \(peripheral.name)  \r")

            // Need to check if we have seen this sensor already.
            // And only add it IF it's not already in the list.
            var found: Bool = false
            for dev in cscDevices
            {
                if dev.uid == peripheral.identifier.UUIDString { found = true; break;}
            }
            if found == false
            {
                let uuidDevice = peripheral.identifier.UUIDString
                peripheralArray.append(peripheral) // add found device to device array to keep a strong reverence to it.
                updateStatusLabel("peripheralArray.append(peripheral)")
                var newSensor = CSCDevice(name:peripheral.name, uid:uuidDevice, paired:false)
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
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        //var enableValue = 1
        //let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
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
        // find this peripheral and change the table entry to show the change in it's status
        cscDevices[pairedRiderIndex].status = "Paired"
        cscDevices[pairedRiderIndex].paired = true
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
        
        //https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.csc_measurement.xml
        
        
        if characteristic.UUID == CSCMeasurementDataUUID
        {
            var wheelData : [UInt32] = CSCTag.getCSCData(characteristic.value!)
            
            let wheelRev = wheelData[0]
            let wheelEvt = wheelData[1]
            let crankRev = wheelData[2]
            let crankEvt = wheelData[3]
            var crevs: UInt32 = 0
            var wrevs: UInt32 = 0
            var adjustedCrankEvt: UInt32 = 0
            var adjustedCrankRev: UInt32 = 0
            var adjustedWheelEvt: UInt32 = 0
            
            print("Wheel Event \(wheelEvt) ms : Crank Event \(crankEvt) ms")
            print("Wheel Revs  \(wheelRev)    : Crank Revs  \(crankRev)")
            
            if crankEvt < prevCrankEvt
            {
                adjustedCrankEvt += 65535
            }
            else
            {
                adjustedCrankEvt = crankEvt
            }
            let crankPeriod = adjustedCrankEvt - prevCrankEvt

            if crankRev < prevCrankRev { adjustedCrankRev = crankRev + 65535 }
            else { adjustedCrankRev = crankRev }
            
            
            if crankPeriod > 0 {
                crevs = (adjustedCrankRev - prevCrankRev) * 60000 / crankPeriod
            }
            else {
                crevs = 0
            }
            

            if wheelEvt < prevWheelEvt
            {
                adjustedWheelEvt += 65535
            }
            else { adjustedWheelEvt = wheelEvt }
            
            let wheelPeriod = adjustedWheelEvt - prevWheelEvt
            
            if firstTime == true
            {
                firstTime = false
                prevWheelRev = wheelRev
            }
            
            if wheelPeriod > 0
            {
                wrevs = ((wheelRev - prevWheelRev) * 60000)/wheelPeriod
            }
            else
            {
                wrevs = 0
            }
            
            prevCrankRev = crankRev
            prevWheelRev = wheelRev
            prevCrankEvt = crankEvt
            prevWheelEvt = wheelEvt
            
            cscDevices[pairedRiderIndex].wheelRevs = Int(wrevs)
            cscDevices[pairedRiderIndex].crankRevs = Int(crevs)
            
            print("Crank Revs:\(crevs): Wh Revs:\(wrevs)\r")
            tableView.reloadData()
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

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cscCellID, forIndexPath: indexPath) as! CSCDeviceCell
//        let cell = tableView.dequeueReusableCellWithIdentifier(cscCellID, forIndexPath: indexPath)
        
        let row = indexPath.row
        let device = cscDevices[row]
        
        cell.device = device
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var sensor = cscDevices[indexPath.row]
        
        pairedRiderIndex = indexPath.row
        printToMyTextView("Selected device: \(sensor.uid), pairedRiderIndex:\(pairedRiderIndex)\r")
        
        //myCentralManager.connectPeripheral(peripheralArray[0], options: nil)
        
        
//        var found: Bool = false
//        var loop: Int = 0
//        for perif in peripheralArray
//        {
//            if sensor.uid == perif.identifier.UUIDString
//            {
//                found = true
//                break
//            }
//            loop += 1
//        }
//        if found
//        {
//            myCentralManager.connectPeripheral(peripheralArray[loop], options: nil)
//            printToMyTextView("Trying device: \(sensor.uid)\r")
//        }
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
