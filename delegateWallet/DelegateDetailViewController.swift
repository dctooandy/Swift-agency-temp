//
//  DelegateDetailViewController.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/17.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit

class DelegateDetailViewController: BaseViewController {
    @IBOutlet var treatImageView : UIImageView!
    @IBOutlet var treatTitleLabel : UILabel!
    
    @IBOutlet var transIDView : UIView!
    @IBOutlet var transIDLabel : UILabel!
    @IBOutlet var transChannelView : UIView!
    @IBOutlet var transChannelLabel : UILabel!
    @IBOutlet var transTypeView : UIView!
    @IBOutlet var transTypeLabel : UILabel!
    @IBOutlet var createTimeView : UIView!
    @IBOutlet var createTimeLabel : UILabel!
    @IBOutlet var transAmountView : UIView!
    @IBOutlet var transAmountLabel : UILabel!
    @IBOutlet var oldCashView : UIView!
    @IBOutlet var oldCashLabel : UILabel!
    @IBOutlet var newCashView : UIView!
    @IBOutlet var newCashLabel : UILabel!
    
    @IBOutlet var treatStatusView : UIView!
    @IBOutlet var treatStatusLabel : UILabel!
    @IBOutlet var treatRemarksView : UIView!
    @IBOutlet var treatRemarksLabel : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "交易明细"
        isShowBottomViewCopyRightView = false
        // Do any additional setup after loading the view.
    }

    static func loadViewFromNib(getCashLogArrayDataDto:GetCashLogArrayDataDto ) -> DelegateDetailViewController {
        let vc = DelegateDetailViewController.loadNib()
   
        return vc
    }
    func configureCell(cashLog:GetCashLogArrayDataDto ,otherDto : GetCashLogOtherDto)
    {
        var image = #imageLiteral(resourceName: "pic-mb-history-wait")
        let statusCode = cashLog.StateCode
        if statusCode == "1"
        {
            image = #imageLiteral(resourceName: "pic-mb-history-sucess")
        }else if statusCode == "0" || statusCode == "2"
        {
            image = #imageLiteral(resourceName: "pic-mb-history-wait")
        }
        else if statusCode == "3"
        {
            image = #imageLiteral(resourceName: "pic-mb-history-cancel")
        }
        // 交易情況
        treatTitleLabel.text = otherDto.ModifyType[cashLog.ModifyType]
        // 交易類型畫面
        treatImageView.image = image
        // 交易時間
        createTimeLabel.text = cashLog.Create_At
        // 交易金額
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
            transAmountLabel.text = "-" + modifyCashString
            transAmountLabel.textColor = #colorLiteral(red: 0.9800047278, green: 0.3345870376, blue: 0.3312225938, alpha: 1)
            
        }else
        {
            let modifyCashRange = modifyCashString.index(after: modifyCashString.startIndex )..<modifyCashString.endIndex
            modifyCashString = String(modifyCashString[modifyCashRange])
            transAmountLabel.text = modifyCashString
            transAmountLabel.textColor = #colorLiteral(red: 0.4054102004, green: 0.7588464618, blue: 0.2288374901, alpha: 1)
        }
        
        // 交易類型
        if cashLog.ChannelName != ""
        {
            transTypeView.isHidden = false
        }else
        {
            transTypeView.isHidden = true
            transTypeLabel.text = cashLog.ChannelName
        }
        //交易前金額
        var oldCashString = currencyFormatter.string(from: NSNumber(value: Float(cashLog.OldCash)!))!
        let oldCashRange = oldCashString.index(after: oldCashString.startIndex )..<oldCashString.endIndex
        oldCashString = String(oldCashString[oldCashRange])
        oldCashLabel.text = oldCashString
        //交易後金額
        var newCashString = currencyFormatter.string(from: NSNumber(value: Float(cashLog.NewCash)!))!
        let newCashRange = newCashString.index(after: newCashString.startIndex )..<newCashString.endIndex
        newCashString = String(newCashString[newCashRange])
        newCashLabel.text = newCashString
        // 交易狀態
        treatStatusLabel.text = otherDto.ModifyType[cashLog.ModifyType]
        // 交易備註
        if let note = cashLog.Notes, cashLog.ModifyType == "201"
        {
            treatRemarksView.isHidden = false
            treatRemarksLabel.text = "上分給" + note
        }else
        {
            treatRemarksView.isHidden = true
        }
        
    }
    @IBAction func dismissViewAndBackToRecordView(_ sender:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
