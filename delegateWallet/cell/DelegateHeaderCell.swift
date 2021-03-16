//
//  DelegateHeaderCell.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/17.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit

class DelegateHeaderCell: UITableViewCell
{
    @IBOutlet var cashLabel : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
