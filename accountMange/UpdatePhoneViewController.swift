//
//  UpdatePhoneViewController.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/16.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Toaster

class UpdatePhoneViewController: BaseViewController {



    @IBOutlet var newPhoneTextField : UITextField!
    @IBOutlet var confirmPhoneTextField : UITextField!
    @IBOutlet var newPhoneHintLabel : UILabel!
    @IBOutlet var confirmPhoneHintLabel : UILabel!
    @IBOutlet var submitButton : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "修改手机号"
        submitButton.isEnabled = false
        bindTextField()
        bindBtn()
        setupDismissTap()
        // Do any additional setup after loading the view.
    }
    private func bindTextField(){
        
        newPhoneTextField.rx.controlEvent(.editingChanged).subscribe(onNext: { [unowned self] in
            if let text = self.newPhoneTextField.text {
                self.newPhoneTextField.text = String(text.prefix(11))
            }
        }).disposed(by: disposeBag)
        
        confirmPhoneTextField.rx.controlEvent(.editingChanged).subscribe(onNext: { [unowned self] in
            if let text = self.confirmPhoneTextField.text {
                self.confirmPhoneTextField.text = String(text.prefix(11))
            }
        }).disposed(by: disposeBag)
        
        let isNewPhoneValid = newPhoneTextField.rx.text.map({$0 ?? ""})
            .map { (str) -> (Bool,String) in
                return (RegexHelper.match(pattern:.phone,input:str),str)
        }
        let isConfirmPhoneValid = confirmPhoneTextField.rx.text.map({$0 ?? ""})
            .map { (str) -> (Bool,String) in
                return (RegexHelper.match(pattern:.phone,input:str),str)
        }
        let isPhoneConsistent = Observable.combineLatest([isNewPhoneValid,isConfirmPhoneValid]).map { (isvalid) -> Bool in
            return isvalid[0].1 == isvalid[1].1
        }
        
        isNewPhoneValid.skip(1).subscribeSuccess {[weak self] (isValid,str) in
            guard let weakSelf = self else { return }
            weakSelf.newPhoneHintLabel.textColor = Themes.falseRedLayerColor
            weakSelf.newPhoneHintLabel.isHidden = isValid
            weakSelf.newPhoneHintLabel.text = str.count > 0 ? Constants.Tiger_Text_Cell_ErrorUserPhoneNoCurrect: Constants.Tiger_Text_Cell_ErrorUserPhoneEmpty
            }.disposed(by: disposeBag)
        
        isConfirmPhoneValid.skip(1).subscribeSuccess {[weak self] (isValid,str) in
            guard let weakSelf = self else { return }
            weakSelf.confirmPhoneHintLabel.textColor = Themes.falseRedLayerColor
            weakSelf.confirmPhoneHintLabel.isHidden = isValid
            weakSelf.confirmPhoneHintLabel.text = str.count > 0 ? Constants.Tiger_Text_Cell_ErrorUserPhoneNoCurrect: Constants.Tiger_Text_Cell_ErrorUserPhoneEmpty
            }.disposed(by: disposeBag)
        
        isConfirmPhoneValid.withLatestFrom(isNewPhoneValid){[$0,$1]}.skip(1).subscribeSuccess {[weak self] (isValid) in
            guard let weakSelf = self else { return }
            let confirmPhone = isValid[0]
            let newPhone = isValid[1]
            let isSamePhone = newPhone.1 == confirmPhone.1
            if confirmPhone.0 {
                weakSelf.confirmPhoneHintLabel.isHidden = isSamePhone
                weakSelf.confirmPhoneHintLabel.text = isSamePhone ? weakSelf.confirmPhoneHintLabel.text : Constants.Tiger_Typeing_Not_Consistent
            } else {
                weakSelf.confirmPhoneHintLabel.isHidden = confirmPhone.0
                weakSelf.confirmPhoneHintLabel.text = confirmPhone.1.count > 0 ? Constants.Tiger_Text_Cell_ErrorUserPhoneNoCurrect: Constants.Tiger_Text_Cell_ErrorUserPhoneEmpty
            }
        }.disposed(by: disposeBag)
        
        let isRegexPass = Observable.combineLatest([isNewPhoneValid,isConfirmPhoneValid]).map { (isvalids) -> Bool in
            isvalids.reduce(true, { (result, arg1) -> Bool in
                let (isValid, _) = arg1
                return result && isValid
            })
        }
        Observable.combineLatest(isRegexPass,isPhoneConsistent){ $0 && $1}.subscribeSuccess({[weak self] (isValid) in
            self?.submitButton.isEnabled = isValid
        }).disposed(by: disposeBag)
    }
    
    private func bindBtn(){
        submitButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let weakSelf = self ,
                let newPhone = weakSelf.confirmPhoneTextField.text,
                let agency = AgencyMemberDto.share else {return}
            Beans.adminService.agencyManage(agencyId: agency.AgencyId, phone: newPhone)
                .subscribeSuccess({[weak self] (agencyResultDto) in
                    guard let weakSelf = self else { return }
                    if agencyResultDto.result {
                        NotificationCenter.default.post(name: NotifyConstant.agencyMemberUpdated, object: AgencyMemberDto.share?.updatePhone(newPhone))
                        Toast.show(msg: "电话修改成功")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            _ = weakSelf.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        Toast.show(msg: "电话修改失敗")
                    }
                }).disposed(by: weakSelf.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    
    func clearAllTextfield(){
        newPhoneTextField.text = ""
        confirmPhoneTextField.text = ""
        newPhoneHintLabel.isHidden = true
        confirmPhoneHintLabel.isHidden = true
        
    }
    
}
