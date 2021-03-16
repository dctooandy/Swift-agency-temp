//
//  DelegateTableViewCell.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/10.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
protocol DelegateTableViewCellDelegate: class {
    func finacialReportButtonPressed()
    func memberListButtonPressed()
    func commissionButtonPressed()
}
class DelegateTableViewCell: UITableViewCell {
    weak var delegate: DelegateTableViewCellDelegate? =  nil
    
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    @IBAction func memberListButtonPressed(_ sender: Any) {
        delegate?.memberListButtonPressed()
    }
    
    @IBAction func financialReportButtonPressed(_ sender: Any) {
        delegate?.finacialReportButtonPressed()
    }
    
    @IBAction func commissionButtonPressed(_ sender: Any) {
        delegate?.commissionButtonPressed()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconWidth = iconWidth.setMultiplier(multiplier: Views.isIPad() ? 0.3 : 0.5)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
