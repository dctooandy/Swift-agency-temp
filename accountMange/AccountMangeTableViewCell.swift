//
//  AccountMangeTableViewCell.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/16.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit

class AccountMangeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTitle(_ title:String){
        titleLabel.text = title
    }
}
