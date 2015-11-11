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
    
    var device: CSCDevice! {
        didSet {
            nameLabel.text = device.name
            macAddressLabel.text = device.macAddress
            statusLabel.text = device.status
            //ratingImageView.image = imageForRating(player.rating)
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
