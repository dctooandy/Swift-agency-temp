//
//  CashOutViewController.swift
//  agency.ios
//
//  Created by AndyChen on 2019/4/18.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import SDWebImageSVGCoder
import Toaster

class CashOutViewController: BaseViewController
{
        var agencyMemberDto : AgencyMemberDto?
    @IBOutlet var bankAccountName : UILabel!
    @IBOutlet var inputMoneyTextfield : UITextField!
    @IBOutlet var selectedView : UIView!
    @IBOutlet var insertBankCardView : UIView!
    @IBOutlet var currentBankLabel : UILabel!
    @IBOutlet var confirmButton : UIButton!
    @IBOutlet var bankImageView : UIImageView!
    // 存款用銀行資料
    var forShowBankNameSelectionArray : [String] = []
    var forShowBankIconSelectionArray : [String] = []
    var forNetTransBankCodeArray : [String] = []
    var forNetTransCurrentBankCodeString : String = ""
    var forNetTransBankSnArray : [String] = []
    var forNetTransCurrentBankSnString : String = ""
    // data source
    @IBOutlet weak var bankViewAspect: NSLayoutConstraint!
    private var _userBankListAtInnerView : Dictionary<String ,AgencyGetUserBankListDataDto>!
    var userBankListAtInnerView :Dictionary<String ,AgencyGetUserBankListDataDto>!
    {
        get{
            return _userBankListAtInnerView
        }
        set{
            _userBankListAtInnerView = newValue
            
        }
    }
    private var _currentChannelMode : CashChannelMode!
    var currentChannelMode : CashChannelMode!
    {
        get{
            return _currentChannelMode
        }
        set{
            _currentChannelMode = newValue
            //            changeUnderViewUIAction(_currentChannelMode)
        }
    }
    private var _cashierChannelAtInnerView : AgencyCashierChannelDto!
    var cashierChannelAtInnerView : AgencyCashierChannelDto!
    {
        get{
            return _cashierChannelAtInnerView
        }
        set{
            _cashierChannelAtInnerView = newValue
            //            setupChannelBorder()
            //            setupSVGUIAndModelView()
            
        }
    }
    var forShowBankChannel : AgencyCashierChannelDataDto!
    private var _agencyBankListAtInnerView : [AgencyBankListDto]!
    var agencyBankListAtInnerView : [AgencyBankListDto]!
    {
        get{
            return _agencyBankListAtInnerView
        }
        set{
            _agencyBankListAtInnerView = newValue
            
        }
    }

    func setupSVGUI()
    {
        forShowBankNameSelectionArray.removeAll()
        forShowBankIconSelectionArray.removeAll()
        forNetTransBankCodeArray.removeAll()
        
        if let dict = userBankListAtInnerView
        {
            for innerDict in dict
            {
                forShowBankNameSelectionArray.append(innerDict.value.BankName)
                forShowBankIconSelectionArray.append(innerDict.value.BankIcon)
                forNetTransBankCodeArray.append(dict.keys.first!)
                
            }
            forNetTransCurrentBankCodeString = forNetTransBankCodeArray[0]
            currentBankLabel.text = forShowBankNameSelectionArray[0]
            let SVGCoder = SDImageSVGCoder.shared
            SDImageCodersManager.shared.addCoder(SVGCoder)
            let SVGImageSize = CGSize(width: 30, height: 30)
            bankImageView.sd_setImage(with: URL(string: forShowBankIconSelectionArray[0]), placeholderImage: nil, options: [], context: [.svgImageSize : SVGImageSize])
        }
    }
    func setupMemberInfo()
    {
        bankAccountName.text = agencyBankListAtInnerView.first?.AccountName
        forNetTransBankSnArray.removeAll()
        if agencyBankListAtInnerView.count > 0
        {
            forNetTransBankSnArray.append((agencyBankListAtInnerView.first?.Sn)!)
            forNetTransCurrentBankSnString = forNetTransBankSnArray[0]
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }

    func setupInputAction()
    {
        inputMoneyTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    @objc func textFieldDidChange(_ textfield : UITextField)
    {
        //        let inputString = textfield.text! + ".00"
        //        let minString = Double(forShowBankChannel.SingleMin!)!
        //        let maxString = Double(forShowBankChannel.SingleMax!)!
        //
        //        if inputString.count == 0
        //        {
        //            print("字數空白")
        //            checkAmount = false
        //        }else if let d = Double (inputString), d >= minString ,  d <= maxString
        //        {
        //            print("可打錢")
        //            checkAmount = true
        //        } else {
        //            print("數目小於最低,或高於最高")
        //            checkAmount = false
        //        }
    }
    func setupActionsheet()
    {
        let alertSheet = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
        alertSheet.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        alertSheet.popoverPresentationController?.sourceView = self.view
        alertSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        alertSheet.addAction(cancelAction)
        
        for i in 0...forShowBankNameSelectionArray.count-1
        {
            var archiveAction : UIAlertAction!
            
            archiveAction = UIAlertAction(title: forShowBankNameSelectionArray[i], style: UIAlertAction.Style.default, handler:
                {
                    action in
                    
                    self.forNetTransCurrentBankCodeString = self.forNetTransBankCodeArray[i]
                    self.currentBankLabel.text = self.forShowBankNameSelectionArray[i]
                    let SVGCoder = SDImageSVGCoder.shared
                    SDImageCodersManager.shared.addCoder(SVGCoder)
                    let SVGImageSize = CGSize(width: 30, height: 30)
                    self.bankImageView.sd_setImage(with: URL(string: self.forShowBankIconSelectionArray[i]), placeholderImage: nil, options: [], context: [.svgImageSize : SVGImageSize])
                    
            })
            alertSheet.addAction(archiveAction)
        }
        present(alertSheet, animated: true, completion: nil)
    }

    // 連網提款
    func getPaymentPayoutOrder(Amount : String , UserBankSn : String)
    {
        Log.i("[NetCall]-提款")
        let dto = AgencyPaymentPayRequestDto(AgencyId: agencyMemberDto?.AgencyId ?? "", Amount: Amount, BankCode: "", ProductTag: "", UserBankSn: UserBankSn)
        Beans.agencyPaymentService.getPayoutOrder(paymentPayRequestDto: dto).subscribeSuccess { (success) in
            
            OperationQueue.main.addOperation {
                
            }
            Log.i("[NetCall]-提款 成功 ")
            }.disposed(by: disposeBag)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bankViewAspect = bankViewAspect.setMultiplier(multiplier: Views.isIPad() ? 5 : 2.86)
        setupDismissTap()
        selectedView.layer.borderColor = UIColor.lightGray.cgColor
        selectedView.layer.borderWidth = 1
        insertBankCardView.layer.borderColor = UIColor.lightGray.cgColor
        insertBankCardView.layer.borderWidth = 1
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSVGUI()
        setupMemberInfo()
        
    }
    @IBAction func selectBankAction(_ sender : UIButton)
    {
        setupActionsheet()
    }
    @IBAction func confirmAction(_ sender : UIButton)
    {
        let amountString = inputMoneyTextfield.text
        if (amountString?.count)! < 1
        {
            Toast.show(msg:"请输入金额")
            
        }else
        {
            getPaymentPayoutOrder(Amount: amountString!, UserBankSn: forNetTransCurrentBankSnString)
        }
    }
    
    //添加銀行卡功能
    @IBAction func addBankCardAction(_ sender : UIButton)
    {
        let newVC = AddBankCardViewController.loadViewFromNib()
        newVC.agencyMemberDto = agencyMemberDto
        newVC.userBankList = userBankListAtInnerView
        newVC.memberBankName = agencyMemberDto?.AgencyRealName
        show(newVC, sender: nil)
        //hostView.mainViewDirectToAddBankCard()
    }

}
extension CashOutViewController : UITextFieldDelegate
{
    // TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }

}

