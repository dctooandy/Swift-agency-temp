//
//  DelegateSubCell.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/17.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit


class DelegateSubCell: UITableViewCell {
    
    @IBOutlet var subImageView : UIImageView!
    @IBOutlet var leftUpLabel : UILabel!
    @IBOutlet var leftDownLabel : UILabel!
    @IBOutlet var rightUpLabel : UILabel!
    @IBOutlet var rightDownLabel : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(cashLog:GetCashLogArrayDataDto ,otherDto : GetCashLogOtherDto){
        
        var amountColor = #colorLiteral(red: 0.4054102004, green: 0.7588464618, blue: 0.2288374901, alpha: 1)
        if let cash = Double(cashLog.ModifyCash) , cash < 0
        {
            amountColor = #colorLiteral(red: 0.9800047278, green: 0.3345870376, blue: 0.3312225938, alpha: 1)
        }
    
        subImageView.image = cashLog.image
        let dateStr = cashLog.Create_At.formatterDateString(currentFormat: .DateTime, to: .slashDate)

        leftUpLabel.text = dateStr
        leftDownLabel.text = otherDto.ModifyType[cashLog.ModifyType]
        rightUpLabel.textColor = amountColor
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.locale = Locale.current
        
        var modifyCashString = currencyFormatter.string(from: NSNumber(value: Float(cashLog.ModifyCash)!))!
        if let cash = Double(cashLog.ModifyCash) , cash < 0
        {
            let offsetIndex: String.Index = modifyCashString.index(modifyCashString.startIndex, offsetBy:1)
            let modifyCashRange = modifyCashString.index(after: offsetIndex )..<modifyCashString.endIndex
            modifyCashString = String(modifyCashString[modifyCashRange])
            rightUpLabel.text = "-" + modifyCashString
        }else
        {
            let modifyCashRange = modifyCashString.index(after: modifyCashString.startIndex )..<modifyCashString.endIndex
            modifyCashString = String(modifyCashString[modifyCashRange])
            rightUpLabel.text = modifyCashString
        }
       
        var newCashString = currencyFormatter.string(from: NSNumber(value: Float(cashLog.NewCash)!))!
        let newCashRange = newCashString.index(after: newCashString.startIndex)..<newCashString.endIndex
        newCashString = String(newCashString[newCashRange])
        rightDownLabel.text = newCashString
    }
}
