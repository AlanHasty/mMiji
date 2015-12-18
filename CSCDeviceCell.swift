//
//  CSCDeviceCell.swift
//  mMiji
//
//  Created by Alan Hasty on 11/11/15.
//  Copyright © 2015 Alan Hasty. All rights reserved.
//

import UIKit

class CSCDeviceCell: UITableViewCell {

        
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var macAddressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cadenceLabel: UILabel!
    @IBOutlet weak var rpmLabel: UILabel!
    
    
    var device: CSCDevice! {
        didSet {
            nameLabel.text = device.name
            macAddressLabel.text = device.uid
            statusLabel.text = device.status
            if device.paired
            {
                cadenceLabel.text = String(device.crankRevs)
                cadenceLabel.hidden = false
                rpmLabel.text = String(device.wheelRevs)
                rpmLabel.hidden = false
            }
            else
            {
                cadenceLabel.hidden = true
                cadenceLabel.text = ""
                rpmLabel.hidden = true
                rpmLabel.text = ""
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
