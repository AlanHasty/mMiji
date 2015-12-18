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
    var uid: String?
    var name: String?
    var paired: Bool
    var status: String?
    var wheelRevs: Int
    var crankRevs: Int
    
    init(name:String?, uid:String?, paired: Bool) {
        self.name = name
        self.macAddress = "bloody Apple"
        self.paired = paired
        self.uid = uid
        self.status = "unknown"
        self.wheelRevs = 60
        self.crankRevs = 0
    }
}