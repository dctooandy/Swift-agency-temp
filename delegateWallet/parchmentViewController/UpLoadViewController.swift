//
//  UpLoadViewController.swift
//  agency.ios
//
//  Created by AndyChen on 2019/4/18.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import Toaster
import DropDown

class UpLoadViewController: BaseViewController {
    
    @IBOutlet weak var uploadMemberTextField: UITextField!
    @IBOutlet weak var inputUploadTextField:UITextField!
    @IBOutlet weak var errorLabelForUploadField: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var plus10Button: UIButton!
    @IBOutlet weak var plus100Button: UIButton!
    @IBOutlet weak var plus1000Button: UIButton!
    
    private lazy var memberDropDown:DropDown = {
        let dropDown = DropDown()
         dropDown.anchorView = uploadMemberTextField
         dropDown.direction = .bottom
         dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)! + 12)
         DropDown.appearance().backgroundColor = UIColor.white
         dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.uploadMemberTextField.text = item
        }
        return dropDown
    }()
    private var ishideDropDown = false
    var memberDto: [MemberDataDto] = [] {
        didSet {

        }
    }
    private var _agencyId: String = ""
    private var _monthType: Int = 1
    private var _searchCond: Int? = nil
    var agencyId: String {
        set {
            self._agencyId = newValue
        }
        get {
            return _agencyId
        }
    }
    
    var searchCond: Int? {
        set {
            self._searchCond = newValue
        }
        get {
            return _searchCond
        }
    }
    var agencyMemberDto : AgencyMemberDto?
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupDismissTap()
        setupTapGesture()
        // Do any additional setup after loading the view.
        getMemberList()
        setLabelGasture()
        initData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLayers()
    }
    private func initData(){
        totalAmountLabel.text = UserWalletInfoDataDto.shared?.remaining
    }
    
    override func updateWallet(_ wallet: ResponseDto<[UserWalletInfoDataDto], UserWalletInfoOtherDto>) {
        guard let wallet = wallet.data.first else {return}
        totalAmountLabel.text = wallet.remaining
    }
    
    func setupTapGesture()
    {
        let taps = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.view!.addGestureRecognizer(taps)
    }
    @objc func handleTapGesture()
    {
        ishideDropDown = true
        self.view.endEditing(true)
        ishideDropDown = false
        memberDropDown.hide()
        if inputUploadTextField.text != ""
        {
            errorLabelForUploadField.isHidden = true
        }else
        {
            errorLabelForUploadField.isHidden = false
        }
    }
    func setLabelGasture()
    {
        
        uploadMemberTextField.rx.text.skip(1).map({$0 ?? ""}).subscribeSuccess {[weak self] (searchText) in
            
            guard let weakSelf = self else {return}
            if searchText.isEmpty {
                weakSelf.memberDropDown.dataSource = weakSelf.memberDto.map{$0.UserName}
            } else {
                weakSelf.memberDropDown.dataSource = weakSelf.memberDto.filter({ (dto) -> Bool in
                    dto.UserName.contains(searchText)
                }).map({$0.UserName})
            }
            if !weakSelf.ishideDropDown && weakSelf.uploadMemberTextField.isFirstResponder {
                weakSelf.memberDropDown.show()
            }
            }.disposed(by: disposeBag)
        
    }
//    @objc func headerDidTap() {
//
//        memberDropDown.dataSource = memberDto.count
//
//        let alertSheet = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.actionSheet)
//        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: { (UIAlertAction) in
//            self.uploadMemberLabel.text = "   选择上分对象"
//            self.uploadMemberLabel.textColor = #colorLiteral(red: 0.8604217172, green: 0.87455374, blue: 0.900455296, alpha: 1)
//        })
//        alertSheet.addAction(cancelAction)
//
//        for i in 0...memberDto.count-1
//        {
//            var archiveAction : UIAlertAction!
//
//            archiveAction = UIAlertAction(title: memberDto[i].UserName, style: UIAlertAction.Style.default, handler:
//                {
//                    action in
//                    self.uploadMemberLabel.text = "  " + self.memberDto[i].UserName
//                    self.uploadMemberLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//            })
//            alertSheet.addAction(archiveAction)
//        }
//        present(alertSheet, animated: true, completion: nil)
//    }
    func setupLayers()
    {
        uploadMemberTextField.layer.borderColor = #colorLiteral(red: 0.8604217172, green: 0.87455374, blue: 0.900455296, alpha: 1)
        uploadMemberTextField.layer.borderWidth = 1
        plus10Button.layer.borderColor = #colorLiteral(red: 0.5686197877, green: 0.7734774351, blue: 0.9999554753, alpha: 1)
        plus100Button.layer.borderColor = #colorLiteral(red: 0.5686197877, green: 0.7734774351, blue: 0.9999554753, alpha: 1)
        plus1000Button.layer.borderColor = #colorLiteral(red: 0.5686197877, green: 0.7734774351, blue: 0.9999554753, alpha: 1)
        plus10Button.layer.borderWidth = 1
        plus100Button.layer.borderWidth = 1
        plus1000Button.layer.borderWidth = 1
    }
    func getMemberList() {
        
        let dto = MemberListDto(agencyId: _agencyId, monthType: _monthType, searchCond: _searchCond)
        Beans.agencyAdminService
            .getMemberList(memberListDto: dto)
            .subscribeSuccess { [weak self](dto) in
                self?.memberDto = dto.data_list
            }.disposed(by: disposeBag)
    }
    // 連網上分
    func getWalletTransfer()
    {
        Log.i("[NetCall]-上分")
        let dto = AgencyWalletTransferRequestDto(AgencyId: agencyMemberDto?.AgencyId ?? "", TransferCash: inputUploadTextField.text!, UserName: uploadMemberTextField.text!)
        Beans.agencyWalletService.walletTransfer(agencyWalletTransferRequestDto: dto).subscribeSuccess {[weak self]  (Agency_WalletTransferDto) in
            guard let weakSelf = self else {return}
            Toast.show(msg: "上分 成功")
            Log.i("[NetCall]-上分 成功")
            guard let agencyMemberDto = AgencyMemberDto.share else {return}
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                Beans.agencyWalletService.userWalletInfo(agencyMemberDto: agencyMemberDto).subscribeSuccess({[weak self] (_) in
                    let newVC = DelegateWalletViewController.loadViewFromNib(agencyMemberDto: agencyMemberDto ,singleSection: true)
                    self?.show(newVC, sender: nil)
                }).disposed(by: weakSelf.disposeBag)
            })
            }.disposed(by: disposeBag)
        
    }
    
    @IBAction func comfirmAction(_ sender: UIButton) {
        if errorLabelForUploadField.isHidden == true , !uploadMemberTextField.text!.isEmpty
        {
            getWalletTransfer()
        }else
        {
            Toast.show(msg: "用户参数错误")
        }
    }
    @IBAction func plusAmountAction(_ sender: UIButton) {
        var inputAmountString = inputUploadTextField.text
        if inputAmountString == ""
        {
            inputAmountString = "0"
        }
        switch sender.tag
        {
        case 1:
            Log.i("加10")
            inputAmountString = String(Int(inputAmountString!)!+10)
        case 2:
            Log.i("加100")
            inputAmountString = String(Int(inputAmountString!)!+100)
        case 3:
            Log.i("加1000")
            inputAmountString = String(Int(inputAmountString!)!+1000)
        default:
            break
        }
        inputUploadTextField.text = inputAmountString
        if inputUploadTextField.text != ""
        {
            errorLabelForUploadField.isHidden = true
        }else
        {
            errorLabelForUploadField.isHidden = false
        }
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
