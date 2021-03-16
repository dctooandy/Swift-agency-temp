//
//  SubTableViewCell.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/10.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit


class SubTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var iconImageView : UIImageView!
    @IBOutlet weak var unReadLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(title:String , icon:UIImage?, center:Bool? , unread:String? = nil){
        titleLabel.textAlignment = (center ?? false ? .center : .left)
        titleLabel.text = title
        iconImageView.image = icon
    }
    
    
    func configureCell(unread:Int ){
        if unread != 0 {
            unReadLabel.isHidden  = false
            unReadLabel.text = "\(unread)"
        } else {
            unReadLabel.isHidden  = true
        }
    }
}
