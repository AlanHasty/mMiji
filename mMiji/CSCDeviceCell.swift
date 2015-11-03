//
//  CSCDeviceCell.swift
//  mMiji
//
//  Created by Alan Hasty on 11/2/15.
//  Copyright © 2015 Alan Hasty. All rights reserved.
//

import UIKit

class CSCDeviceCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var macAddress: UILabel!
    @IBOutlet weak var status: UILabel!
    
    var device: CSCDevice! {
        didSet {
            name.text = device.name
            macAddress.text = "unknown"
            status.text = "unknown"
            //ratingImageView.image = imageForRating(player.rating)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
