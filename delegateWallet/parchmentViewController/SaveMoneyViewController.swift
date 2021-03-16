//
//  SaveMoneyViewController.swift
//  agency.ios
//
//  Created by AndyChen on 2019/4/18.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import SDWebImageSVGCoder
import Toaster

class SaveMoneyViewController: BaseViewController
{
    var agencyMemberDto : AgencyMemberDto?
    // 存款用的checkMarkLabel
    @IBOutlet var addPlusLabel:UILabel!
    @IBOutlet var gradientLayerView : UIView!
    @IBOutlet var channelContainerView1: UIView!
    @IBOutlet var channelContainerView2: UIView!
    @IBOutlet var channelContainerView3: UIView!
    @IBOutlet var channelContainerView4: UIView!
    @IBOutlet var channelContainerView5: UIView!
    
    @IBOutlet var underStackView : UIStackView!
    @IBOutlet var underView1 : UIView!
    @IBOutlet var underView2 : UIView!
    @IBOutlet var underView3 : UIView!
    @IBOutlet var selectBankView : UIView!
    @IBOutlet var underView4 : UIView!
    @IBOutlet var addBankView : UIView!
    @IBOutlet var underView5 : UIView!
    @IBOutlet var underView6 : UIView!
    @IBOutlet weak var underViewHeight: NSLayoutConstraint!
    // 存款成功頁面
    @IBOutlet var bankPruchaseResultView : UIView!
    @IBOutlet var titlebankShortNameLabel : UILabel!
    @IBOutlet var titleBankImageView : UIImageView!
    @IBOutlet var titlebankNameLabel : UnderlinedLabel!
    @IBOutlet var userNameLabel : UILabel!
    @IBOutlet var cardNumberLabel : UILabel!
    @IBOutlet var amountLabel : UILabel!
    @IBOutlet var plusStringLabel : UILabel!
    @IBOutlet var unionQRCodeResultContainerView : UIView!
    
     @IBOutlet weak var keyboard:NSLayoutConstraint!
    
    // 單筆存款說明
    @IBOutlet var descriptionLabel : UILabel!
    var forShowBankNameSelectionArray : [String] = []
    var forShowBankIconSelectionArray : [String] = []
    var forNetTransBankCodeArray : [String] = []
    var forNetTransCurrentBankCodeString : String = ""
    var forNetTransBankSnArray : [String] = []
    var forNetTransCurrentBankSnString : String = ""
    // under View
    @IBOutlet var supportBankStackView : UIStackView!
    @IBOutlet var currentBankLabel : UILabel!
    @IBOutlet var confirmButton : UIButton!
    @IBOutlet var checkMarkButton : UIButton!
    var checkMarkOn : Bool! = true
    var checkAmount : Bool! = false
    // 輸入金額
    @IBOutlet var inputMoneyTextfield : UITextField!
    @IBOutlet var bankImageView : UIImageView!
    var unionQRCodeResultView : UnionQRCodeResultView!
    var forShowBankChannel : AgencyCashierChannelDataDto!
//    var agencyBankListAtInnerView : [AgencyBankListDto]!
    var userBankListAtInnerView : AgencyGetUserBankListDto!
    // MARK: Detect keyboard height
    var selectTextField: UITextField!
    // 成功回傳值
    
    // 網銀
    private var _agServiceNetBankSuccessData: AgencyPaymentPayBankDataDto?
    var agServiceNetBankSuccessData: AgencyPaymentPayBankDataDto?
    {
        get{
            return _agServiceNetBankSuccessData
        }
        set{
            _agServiceNetBankSuccessData = newValue
            if _agServiceNetBankSuccessData != nil
            {
                self.setupBankPurchaseResultView()
            }
        }
    }
    //微信
    private var _agServiceWeChatSuccessData : AgencyPaymentPayThirdpayDataDto!
    var agServiceWeChatSuccessData : AgencyPaymentPayThirdpayDataDto!
    {
        get{
            return _agServiceWeChatSuccessData
        }
        set{
            _agServiceWeChatSuccessData = newValue
            if _agServiceWeChatSuccessData != nil
            {
                self.setupWeChatFuncAction()
            }
        }
    }
    // 銀聯
    private var _agServiceUnionQRCodeSuccessData : AgencyPaymentPayThirdpayDataDto!
    var agServiceUnionQRCodeSuccessData : AgencyPaymentPayThirdpayDataDto!
    {
        get{
            return _agServiceUnionQRCodeSuccessData
        }
        set{
            _agServiceUnionQRCodeSuccessData = newValue
            if _agServiceUnionQRCodeSuccessData != nil
            {
                self.setupUnionQRcodeResultContainerView()
            }
            else
            {
                //                self.setupUnionQRcodeResultContainerView()
            }
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
            changeUnderViewUIAction(_currentChannelMode)
        }
    }
    private var _cashierChannelAtInnerView :[AgencyCashierChannelDataDto]!
    var cashierChannelAtInnerView : [AgencyCashierChannelDataDto]!
    {
        get{
            return _cashierChannelAtInnerView
        }
        set{
            _cashierChannelAtInnerView = newValue

        }
    }
    func setupSVGUIAndModelView()
    {
        for i in 1...5
        {
            if let innerView = self.view.viewWithTag(i)
            {
                innerView.isHidden = true
                for subview in innerView.subviews
                {
                    subview.removeFromSuperview()
                }
            }
        }
        let SVGCoder = SDImageSVGCoder.shared
        SDImageCodersManager.shared.addCoder(SVGCoder)
        let SVGImageSize = CGSize(width: 30, height: 30)
        var alreadySetCashChannel = false
        for i in 0...(cashierChannelAtInnerView.count-1)
        {
            let data = cashierChannelAtInnerView[i]
            let saveMoneyUpModelView = SaveMoneyUpModelView.loadNib()
            let containerView = self.view.viewWithTag(i+1)
            var frame = saveMoneyUpModelView.frame
            frame.size = (containerView?.frame.size)!
            saveMoneyUpModelView.frame = frame
            containerView?.addSubview(saveMoneyUpModelView)
            containerView?.isHidden = false
            saveMoneyUpModelView.channelImageView.sd_setImage(with: URL(string: data.ChannelIcon!), placeholderImage: nil, options: [], context: [.svgImageSize : SVGImageSize])
            saveMoneyUpModelView.channelLabel.text = data.ChannelName
            saveMoneyUpModelView.channelTapButton.tag = i+1
            //            if data.ChannelName?.caseInsensitiveCompare("極速通道") == ComparisonResult.orderedSame
            //            {
            //                saveMoneyUpModelView.channelTapButton.tag = CashChannelMode.FastChannel.rawValue
            //            }
            //            if data.ChannelName?.caseInsensitiveCompare("銀聯") == ComparisonResult.orderedSame
            //            {
            //                saveMoneyUpModelView.channelTapButton.tag = CashChannelMode.SilverChannel.rawValue
            //            }
            //            if data.ChannelName?.caseInsensitiveCompare("支付宝") == ComparisonResult.orderedSame
            //            {
            //                saveMoneyUpModelView.channelTapButton.tag = CashChannelMode.AlipayChannel.rawValue
            //            }
            //            if data.ChannelName?.caseInsensitiveCompare("UNIONPAY") == ComparisonResult.orderedSame
            //            {
            //                saveMoneyUpModelView.channelTapButton.tag = CashChannelMode.UnionChannel.rawValue
            //            }
            
            if alreadySetCashChannel == false
            {
                alreadySetCashChannel = true
                saveMoneyUpModelView.channelTapButton.sendActions(for: .touchUpInside)
            }
            
        }
    }

    func setupChannelBorder()
    {
        channelContainerView1.layer.borderColor = Themes.grayLayer.cgColor
        channelContainerView2.layer.borderColor = Themes.grayLayer.cgColor
        channelContainerView3.layer.borderColor = Themes.grayLayer.cgColor
        channelContainerView4.layer.borderColor = Themes.grayLayer.cgColor
        channelContainerView5.layer.borderColor = Themes.grayLayer.cgColor
        addBankView.layer.borderColor = Themes.grayLayer.cgColor
        selectBankView.layer.borderColor = Themes.grayLayer.cgColor
        
        channelContainerView1.layer.borderWidth = 1
        channelContainerView2.layer.borderWidth = 1
        channelContainerView3.layer.borderWidth = 1
        channelContainerView4.layer.borderWidth = 1
        channelContainerView5.layer.borderWidth = 1
        addBankView.layer.borderWidth = 1
        selectBankView.layer.borderWidth = 1
        
        addBankView.applyCornerRadius()
        selectBankView.applyCornerRadius()
    }

    func changeUnderViewUIAction(_ sender : CashChannelMode)
    {
        switch sender
        {
        case .FastChannel:
            Log.i("極速")
            underView1.isHidden = true
            underView2.isHidden = false
            underView3.isHidden = false
            underView4.isHidden = true
            underView5.isHidden = true
            underView6.isHidden = false
        case .SilverChannel:
            Log.i("銀聯")
            underView1.isHidden = false
            underView2.isHidden = false
            underView3.isHidden = false
            underView4.isHidden = false
            underView5.isHidden = true
            underView6.isHidden = false
        case .AlipayChannel:
            Log.i("支付宝")
            underView1.isHidden = true
            underView2.isHidden = false
            underView3.isHidden = true
            underView4.isHidden = true
            underView5.isHidden = false
            underView6.isHidden = false
        case .UnionChannel:
            Log.i("UNIONPAY")
            underView1.isHidden = true
            underView2.isHidden = false
            underView3.isHidden = true
            underView4.isHidden = true
            underView5.isHidden = true
            underView6.isHidden = false
        case . NetBankChannel:
            Log.i("網銀")
            underView1.isHidden = true
            underView2.isHidden = false
            underView3.isHidden = false
            underView4.isHidden = true
            underView5.isHidden = true
            underView6.isHidden = false
        case . WeChatChannel:
            Log.i("微信")
            underView1.isHidden = true
            underView2.isHidden = false
            underView3.isHidden = true
            underView4.isHidden = true
            underView5.isHidden = true
            underView6.isHidden = false
        case . UnionQRCodeChannel:
            Log.i("銀聯QRCode")
            underView1.isHidden = true
            underView2.isHidden = false
            underView3.isHidden = true
            underView4.isHidden = true
            underView5.isHidden = true
            underView6.isHidden = false
        case .None:
            break
        }
        view.layoutIfNeeded()
        self.underViewHeight.constant = self.underStackView.frame.height + 20
        setupChannelData(sender)
    }
    func setupChannelData(_ sender : CashChannelMode)
    {
        
        forShowBankNameSelectionArray.removeAll()
        forShowBankIconSelectionArray.removeAll()
        forNetTransBankCodeArray.removeAll()
        forNetTransBankSnArray.removeAll()
        bankImageView.image = nil
        
        // 選擇銀行View
        descriptionLabel.text = forShowBankChannel.SingleMin! + "~" + forShowBankChannel.SingleMax! + (forShowBankChannel.Message ?? "")
        if sender == .NetBankChannel
        {
            if forShowBankChannel.SupportBankCode != nil
            {
                if let dict = forShowBankChannel.SupportBankCode
                {
                    for innerDict in dict
                    {
                        forShowBankNameSelectionArray.append(innerDict.value.BankName!)
                        forShowBankIconSelectionArray.append(innerDict.value.BankIcon!)
                        forNetTransBankCodeArray.append(dict.keys.first!)
                    }
                }
                forNetTransCurrentBankCodeString = forNetTransBankCodeArray[0]
                currentBankLabel.text = forShowBankNameSelectionArray[0]
                let SVGCoder = SDImageSVGCoder.shared
                SDImageCodersManager.shared.addCoder(SVGCoder)
                let SVGImageSize = CGSize(width: 30, height: 30)
                bankImageView.sd_setImage(with: URL(string: forShowBankIconSelectionArray[0]), placeholderImage: nil, options: [], context: [.svgImageSize : SVGImageSize])
            }
        }else if sender == .FastChannel
        {
            if forShowBankChannel.SupportBankCode != nil
            {
                if let dict = forShowBankChannel.SupportBankCode
                {
                    forShowBankNameSelectionArray.removeAll()
                    forShowBankIconSelectionArray.removeAll()
                    forNetTransBankCodeArray.removeAll()
                    
                    for innerDict in dict
                    {
                        forShowBankNameSelectionArray.append(innerDict.value.BankName!)
                        forShowBankIconSelectionArray.append(innerDict.value.BankIcon!)
                        forNetTransBankCodeArray.append(dict.keys.first!)
                    }
                }
                forNetTransCurrentBankCodeString = forNetTransBankCodeArray[0]
                currentBankLabel.text = forShowBankNameSelectionArray[0]
                let SVGCoder = SDImageSVGCoder.shared
                SDImageCodersManager.shared.addCoder(SVGCoder)
                let SVGImageSize = CGSize(width: 30, height: 30)
                bankImageView.sd_setImage(with: URL(string: forShowBankIconSelectionArray[0]), placeholderImage: nil, options: [], context: [.svgImageSize : SVGImageSize])
            }
        }else if sender == .SilverChannel
        {
            // 支援銀行 View
            var bankNameArray :[String] = []
            if forShowBankChannel.SupportBankCode != nil
            {
                if let dict = forShowBankChannel.SupportBankCode
                {
                    for innerDict in dict
                    {
                        bankNameArray.append(innerDict.value.BankName!)
                    }
                    for i in 1...bankNameArray.count
                    {
                        if i < 4
                        {
                            let currentLabel = supportBankStackView.viewWithTag(i) as!UILabel
                            currentLabel.isHidden = false
                            currentLabel.text = bankNameArray[i-1]
                        }
                    }
                }
            }
            
            if let bankInfoArray = forShowBankChannel.Info?.UserBank
            {
                
                for bankInfo in bankInfoArray
                {
                    let labelString = (bankInfo.BankData?.BankName)! + bankInfo.AccountNo!
                    forShowBankNameSelectionArray.append(labelString)
                    forShowBankIconSelectionArray.append((bankInfo.BankData?.BankIcon)!)
                    forNetTransBankCodeArray.append(bankInfo.AccountBank!)
                    forNetTransBankSnArray.append(bankInfo.Sn!)
                }
            }
            
            forNetTransCurrentBankSnString = forNetTransBankSnArray.count == 0 ? "" : forNetTransBankSnArray[0]
            forNetTransCurrentBankCodeString = forNetTransBankCodeArray.count == 0 ? "" : forNetTransBankCodeArray[0]
            currentBankLabel.text = forShowBankNameSelectionArray.count == 0 ? "" : forShowBankNameSelectionArray[0]
            let SVGCoder = SDImageSVGCoder.shared
            SDImageCodersManager.shared.addCoder(SVGCoder)
            let SVGImageSize = CGSize(width: 30, height: 30)
            if forShowBankIconSelectionArray.count == 0 { return }
            bankImageView.sd_setImage(with: URL(string: forShowBankIconSelectionArray[0]), placeholderImage: nil, options: [], context: [.svgImageSize : SVGImageSize])
        }
    }
    // 連網打錢
    func getPaymentPayBank(Amount : String , BankCode : String , ProductTag : String , UserBankSn : String)
    {
        Log.i("[NetCall]-打錢 到銀行")
        let dto = AgencyPaymentPayRequestDto(AgencyId: agencyMemberDto?.AgencyId ?? "", Amount: Amount, BankCode: BankCode, ProductTag: ProductTag, UserBankSn: UserBankSn)
        Beans.agencyPaymentService.getPaymentPayBank(paymentPayRequestDto: dto).subscribeSuccess { (PaymentPayBankDataDto) in
            self.agServiceNetBankSuccessData = PaymentPayBankDataDto
            OperationQueue.main.addOperation {
                
            }
            Log.i("[NetCall]-打錢 到銀行成功 : \(PaymentPayBankDataDto)")
        }.disposed(by: disposeBag)
    }
    func getPaymentPayThirdpay(Amount : String , ProductTag : String , UserBankSn : String)
    {
        Log.i("[NetCall]-打錢 到第三方")
        let dto = AgencyPaymentPayRequestDto(AgencyId: agencyMemberDto?.AgencyId ?? "", Amount: Amount, BankCode: "", ProductTag: ProductTag, UserBankSn: UserBankSn)
        Beans.agencyPaymentService.getPaymentThirdpay(paymentPayRequestDto: dto).subscribeSuccess { (PaymentPayThirdpayDataDto) in
            self.agServiceWeChatSuccessData = PaymentPayThirdpayDataDto
            OperationQueue.main.addOperation {
                
            }
            Log.i("[NetCall]-打錢 到第三方成功 : \(PaymentPayThirdpayDataDto)")
            }.disposed(by: disposeBag)
    }
    func getPaymentUnionPayBank(Amount : String , BankCode : String , ProductTag : String , UserBankSn : String)
    {
        Log.i("[NetCall]-打錢 到銀聯")
        let dto = AgencyPaymentPayRequestDto(AgencyId: agencyMemberDto?.AgencyId ?? "", Amount: Amount, BankCode: BankCode, ProductTag: ProductTag, UserBankSn: UserBankSn)
        Beans.agencyPaymentService.getPaymentThirdpay(paymentPayRequestDto: dto).subscribeSuccess { (PaymentPayThirdpayDataDto) in
            self.agServiceUnionQRCodeSuccessData = PaymentPayThirdpayDataDto
            OperationQueue.main.addOperation {
                
            }
            Log.i("[NetCall]-打錢 到銀聯成功 : \(PaymentPayThirdpayDataDto)")
            }.disposed(by: disposeBag)
    }
    // UI
    func setupBankPurchaseResultView()
    {
        OperationQueue.main.addOperation {
            self.bankPruchaseResultView.isHidden = false
            self.titlebankShortNameLabel.text = self.agServiceNetBankSuccessData?.bankCode
            self.titlebankNameLabel.text = self.agServiceNetBankSuccessData?.bankName
            self.titlebankNameLabel.textColor = UIColor.white
            let SVGCoder = SDImageSVGCoder.shared
            SDImageCodersManager.shared.addCoder(SVGCoder)
            let SVGImageSize = CGSize(width: 30, height: 30)
            self.titleBankImageView.sd_setImage(with: URL(string: (self.agServiceNetBankSuccessData?.BankIcon)!), placeholderImage: nil, options: [], context: [.svgImageSize : SVGImageSize])
            
            self.userNameLabel.text = self.agServiceNetBankSuccessData?.name
            self.cardNumberLabel.text = self.agServiceNetBankSuccessData?.bankAccount
            self.amountLabel.text = self.agServiceNetBankSuccessData?.Amount
            self.plusStringLabel.text = self.agServiceNetBankSuccessData?.remark
        }
    }
    func setupWeChatFuncAction()
    {
        OperationQueue.main.addOperation {
            if UIApplication.shared.canOpenURL(URL(string: (self.agServiceWeChatSuccessData?.PayUrl)!)!)
            {
                UIApplication.shared.open((URL(string: (self.agServiceWeChatSuccessData?.PayUrl)!)!), options: [:], completionHandler: nil)
                self.agServiceWeChatSuccessData = nil
//                self.hostView.mainTableView.reloadData()
//                self.hostView.scrollToTop()
            }
            else
            {
                Toast.show(msg: Constants.Tiger_ToastError_WebPageUrlError)
            }
        }
    }
    func setupUnionQRcodeResultContainerView()
    {
        unionQRCodeResultContainerView.isHidden = false
        unionQRCodeResultView = UnionQRCodeResultView.loadNib()
        var frame = unionQRCodeResultView.frame
        frame.size = unionQRCodeResultContainerView.frame.size
        unionQRCodeResultView.frame = frame
        unionQRCodeResultContainerView.addSubview(unionQRCodeResultView)
        unionQRCodeResultView.hostView = self
        unionQRCodeResultView.unionQRCodeSuccessDataAtResultView = agServiceUnionQRCodeSuccessData
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChannelBorder()
        setupDismissTap()
        setDetectKeyboard()
        setupInputAction()
        checkMarkOn = false
        setupCheckMarkButton()
        setupKeyboard(keyboard)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupSVGUIAndModelView()
        checkMarkButton.setImage(nil, for: .normal)
        setupLayerView()
    }
    func setDetectKeyboard()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    func setupInputAction()
    {
        inputMoneyTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    func setupCheckMarkButton()
    {
        checkMarkButton.layer.borderWidth = 1
        checkMarkButton.layer.borderColor = UIColor.black.cgColor
    }
    func setupLayerView()
    {
        gradientLayerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-40, height: 60)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientLayerView.bounds
        gradientLayer.colors = [Themes.leadingBlueLayer.cgColor,Themes.middleBlueLayer.cgColor,Themes.traillingBlueLayer.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0,0.5, 1]
        gradientLayerView.layer.addSublayer(gradientLayer)
    }

    @objc func keyboardDidShow(_ notification: Notification)
    {
        
        if selectTextField == nil { return }
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
//            if (self.hostView.customTableviewModeFlag == MainTableviewMode.SaveTransOutMode)
//            {
//                hostView.mainTableView.scrollToKeyboardTop(keyboardHeight: keyboardFrame.cgRectValue.height)
//            }
            selectTextField = nil
        }
    }
    func returnChannelMode(_ sender : String) -> CashChannelMode
    {
        switch sender
        {
        case "極速通道":
            return .FastChannel
        case "銀聯":
            return .SilverChannel
        case "支付宝":
            return .AlipayChannel
        case "UNIONPAY":
            return .UnionChannel
        case "网银":
            return .NetBankChannel
        case "微信":
            return .WeChatChannel
        case "银联QRCode":
            return .UnionQRCodeChannel
        default:
            return .None
        }
    }
    func returnChannelName(_ sender : CashChannelMode) -> String
    {
        switch sender
        {
        case .FastChannel:
            return "極速通道"
        case .SilverChannel:
            return "銀聯"
        case .AlipayChannel:
            return "支付宝"
        case .UnionChannel:
            return "UNIONPAY"
        case .NetBankChannel:
            return "网银"
        case .WeChatChannel:
            return "微信"
        case .UnionQRCodeChannel:
            return "银联QRCode"
        default :
            return ""
        }
    }
    func setupActionsheet()
    {
        
        let alertSheet = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alertSheet.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        alertSheet.popoverPresentationController?.sourceView = self.view
        alertSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
        alertSheet.addAction(cancelAction)
        
        if forShowBankNameSelectionArray.count == 0 {
            let archiveAction = UIAlertAction(title: "无资料", style: .default, handler: nil)
            alertSheet.addAction(archiveAction)
            present(alertSheet, animated: true, completion: nil)
            return
        }
        
        for i in 0...forShowBankNameSelectionArray.count-1
        {
            var archiveAction : UIAlertAction!
            
            archiveAction = UIAlertAction(title: forShowBankNameSelectionArray[i], style: UIAlertAction.Style.default, handler:
                {
                    action in
                    if self.currentChannelMode == .SilverChannel
                    {
                        self.forNetTransCurrentBankSnString = self.forNetTransBankSnArray[i]
                    }
                    
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

    // IBAction
    @IBAction func handleForChangeRadioImage(_ sender : UIButton)
    {
        let onImage = UIImage(named: "RadioOn")
        let offImage = UIImage(named: "RadioOff")
        for i in 1...5
        {
            if let innerView = self.view.viewWithTag(i)
            {
                
                if let modelView = innerView.viewWithTag(9527) as? SaveMoneyUpModelView
                {
                    if i == sender.tag
                    {
                        if bankPruchaseResultView.isHidden == false
                        {
                            agServiceNetBankSuccessData = nil
//                            netBankSuccessDataAtInnerView = nil
                            bankPruchaseResultView.isHidden = true
//                            hostView.hgServiceNetBankSuccessData = nil
                        }
                        
                        forShowBankChannel = cashierChannelAtInnerView[sender.tag-1]
                        modelView.channelRadioImageView.image = onImage
                        currentChannelMode = returnChannelMode(forShowBankChannel.ChannelName!)
                    }else
                    {
                        modelView.channelRadioImageView.image = offImage
                    }
                }
            }
        }
    }
    @IBAction func selectBankAction(_ sender : UIButton)
    {
        setupActionsheet()
    }
    @IBAction func checkMarkSwitchAction(_ sender : UIButton?)
    {
        checkMarkOn = !checkMarkOn
        let onImage = UIImage(named: "web-checkMark")
        if checkMarkOn == true
        {
            checkMarkButton.setImage(onImage, for: .normal)
            addPlusLabel.textColor = #colorLiteral(red: 0.2543779016, green: 0.6179664731, blue: 1, alpha: 1)
        }else
        {
            checkMarkButton.setImage(nil, for: .normal)
            addPlusLabel.textColor = #colorLiteral(red: 0.9800047278, green: 0.3345870376, blue: 0.3312225938, alpha: 1)
        }
    }
    @IBAction func confirmButtonAction(_ sender: UIButton)
    {
        let currentAmount = inputMoneyTextfield.text!
        let productTag = forShowBankChannel.ProductTag!
        let userBankSN = (currentChannelMode == .SilverChannel) ? forNetTransCurrentBankSnString : ""
        if  checkAmount == true
        {
//            hostView.addBlurView()
//            hostView.addAndStartSpiner()
//            hostView.view.isUserInteractionEnabled = false
            switch currentChannelMode
            {
            case CashChannelMode.FastChannel? :
                Log.i("極速 確認")
                getPaymentPayBank(
                    Amount: currentAmount,
                    BankCode: forNetTransCurrentBankCodeString,
                    ProductTag: productTag,
                    UserBankSn: userBankSN)
            case CashChannelMode.SilverChannel? :
                Log.i("銀聯 確認")
                getPaymentUnionPayBank(
                    Amount: currentAmount,
                    BankCode: forNetTransCurrentBankCodeString,
                    ProductTag: productTag,
                    UserBankSn: userBankSN)
            case CashChannelMode.AlipayChannel? :
                Log.i("支付寶 確認")
                if checkMarkOn == false
                {
//                    hostView.removeBlurView()
//                    hostView.removeSpiner()
//                    hostView.view.isUserInteractionEnabled = true
                    Toast.show(msg: "请勾选填写附言信息")
                }else
                {
                    getPaymentPayThirdpay(
                        Amount: currentAmount,
                        ProductTag: productTag,
                        UserBankSn: userBankSN)
                }
            case CashChannelMode.UnionChannel? :
                Log.i("UnionPAY 確認")
                getPaymentPayThirdpay(
                    Amount: currentAmount,
                    ProductTag: productTag,
                    UserBankSn: userBankSN)
            case CashChannelMode.NetBankChannel? :
                Log.i("網銀 確認")
                getPaymentPayBank(
                    Amount: currentAmount,
                    BankCode: forNetTransCurrentBankCodeString,
                    ProductTag: productTag,
                    UserBankSn: userBankSN)
            case CashChannelMode.WeChatChannel? :
                Log.i("微信 確認")
                getPaymentPayThirdpay(
                    Amount: currentAmount,
                    ProductTag: productTag,
                    UserBankSn: userBankSN)
            case CashChannelMode.UnionQRCodeChannel? :
                Log.i("銀聯QRCode 確認")
                getPaymentPayThirdpay(
                    Amount: currentAmount,
                    ProductTag: productTag,
                    UserBankSn: userBankSN)
            case CashChannelMode.None? :
                Log.i("")
            default:
                break
            }
        }else
        {
            Toast.show(msg: "数目小于最低,或高于最高")
        }
    }
    @IBAction func dismissResultViewAction(_ sender : UIButton?)
    {
        agServiceNetBankSuccessData = nil
//        netBankSuccessDataAtInnerView = nil
        bankPruchaseResultView.isHidden = true
//        hostView.hgServiceNetBankSuccessData = nil
//        hostView.mainTableView.reloadData()
//        hostView.scrollToTop()
    }
    @IBAction func directToCheckListAction(_ sender:UIButton)
    {
        agServiceNetBankSuccessData = nil
//        netBankSuccessDataAtInnerView = nil
        bankPruchaseResultView.isHidden = true
        self.navigationController?.popViewController(animated: true)
//        hostView.hgServiceNetBankSuccessData = nil
        // 加入CheckList Mode
//        if hostView.hgServiceCashflowAll != nil
//        {
//            hostView.mainViewDirectToCashflowRecord()
//        }else
//        {
//            let startDate = hostView.cashflowRecordCalendarDateArray[0]
//            let endDate = hostView.cashflowRecordCalendarDateArray[1]
//            hostView.currentCashflowRecordFlag = CashflowRecordFlag.All
//            hostView.getCashLogAll(startDate: startDate, endDate: endDate, page: "1", more : false)
//        }
        //        hostView.mainTableView.reloadData()
        //        hostView.scrollToTop()
    }
    @IBAction func copyLabelTextAction(_ sender : UIButton)
    {
        switch sender.tag
        {
        case 1:
            Log.i("Copy 名字")
            UIPasteboard.general.string = userNameLabel.text
            Toast.show(msg:"已複製 姓名")
        case 2:
            Log.i("Copy 卡號")
            UIPasteboard.general.string = cardNumberLabel.text
            Toast.show(msg:"已複製 卡号")
        case 3:
            Log.i("Copy 金額")
            UIPasteboard.general.string = amountLabel.text
            Toast.show(msg:"已複製 金额")
        case 4:
            Log.i("Copy 附言")
            UIPasteboard.general.string = plusStringLabel.text
            Toast.show(msg:"已複製 附言")
        default:
            break
        }
    }

}

extension SaveMoneyViewController : UITextFieldDelegate
{
    // TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == inputMoneyTextfield
        {
            selectTextField = textField
        }
    }
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textfield : UITextField)
    {
        let inputString = textfield.text! + ".00"
        let minString = Double(forShowBankChannel.SingleMin!)!
        let maxString = Double(forShowBankChannel.SingleMax!)!
        
        if inputString.count == 0
        {
            Log.i("字數空白")
            checkAmount = false
        }else if let d = Double (inputString), d >= minString ,  d <= maxString
        {
            Log.i("可打錢")
            checkAmount = true
        } else {
            Log.i("數目小於最低,或高於最高")
            checkAmount = false
        }
    }
    
}
