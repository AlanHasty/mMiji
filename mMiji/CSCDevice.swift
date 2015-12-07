//
//  CSCDevice.swift
//  mMiji
//
//  Created by Alan Hasty on 10/28/15.
//  Copyright © 2015 Alan Hasty. All rights reserved.
//

import Foundation
import UIKit

struct CSCDevice {
    var macAddress: String?
    var name: String?
    var paired: Bool?
    var status: String?
    var wheelRevs: Int?
    var crankRevs: Int?
    
    init(name:String?, macAddress:String?, paired: Bool?) {
        self.name = name
        self.macAddress = macAddress
        self.paired = paired
        self.status = "unknown"
        self.wheelRevs = 0
        self.crankRevs = 0
    }
}