//
//  PersonalInfoCell.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/11.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit

class PersonalInfoCell: UITableViewCell {
    @IBOutlet var userNameLabel : UILabel!
    @IBOutlet var cashLabel : UILabel!
    @IBOutlet var badge1 : UIView!
    @IBOutlet var badge2 : UIView!
    @IBOutlet var badge3 : UIView!
    @IBOutlet var badge4 : UIView!
    @IBOutlet var badge5 : UIView!
    @IBOutlet var blackLineLabel : UILabel!
    @IBOutlet var blueLineLabel : UILabel!
    var agencyMemberDto : AgencyMemberDto?
    private var _infoData : ResponseDto<[UserWalletInfoDataDto],UserWalletInfoOtherDto>?
    var infoData : ResponseDto<[UserWalletInfoDataDto],UserWalletInfoOtherDto>?
    {
        get{
            return _infoData
        }
        set{
            _infoData = newValue
            setupCellUI()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setupCellUI()
    {
        if let userInfo = infoData?.data.first
        {
            userNameLabel.text = agencyMemberDto?.AgencyName
            
            cashLabel.text = userInfo.remaining
            var blueLineLabelFrame = blueLineLabel.frame
            let b1X = badge1.frame.minX
            let b2X = badge2.frame.maxX
            let b3X = badge3.frame.maxX
            let b4X = badge4.frame.maxX
            let b5X = badge5.frame.maxX
            switch userInfo.Level
            {
                
            case "0" :
                blueLineLabelFrame.size.width = 0
                badge2.backgroundColor = UIColor.black
                badge3.backgroundColor = UIColor.black
                badge4.backgroundColor = UIColor.black
            case "1" :
                blueLineLabelFrame.size.width = b2X - b1X
                badge2.backgroundColor = Themes.infoLineLabelBlue
                badge3.backgroundColor = UIColor.black
                badge4.backgroundColor = UIColor.black
            case "2" :
                blueLineLabelFrame.size.width = b3X - b1X
                badge2.backgroundColor = Themes.infoLineLabelBlue
                badge3.backgroundColor = Themes.infoLineLabelBlue
                badge4.backgroundColor = UIColor.black
            case "3" :
                blueLineLabelFrame.size.width = b4X - b1X
                badge2.backgroundColor = Themes.infoLineLabelBlue
                badge3.backgroundColor = Themes.infoLineLabelBlue
                badge4.backgroundColor = Themes.infoLineLabelBlue
            case "4" :
                blueLineLabelFrame.size.width = b5X - b1X
                badge2.backgroundColor = Themes.infoLineLabelBlue
                badge3.backgroundColor = Themes.infoLineLabelBlue
                badge4.backgroundColor = Themes.infoLineLabelBlue
            default :
                break
            }
            OperationQueue.main.addOperation {
                
                UIView.animate(withDuration: 0.5) {
                    self.blueLineLabel.frame = blueLineLabelFrame
                }
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
