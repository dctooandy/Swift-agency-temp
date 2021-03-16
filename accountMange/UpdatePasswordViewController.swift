//
//  UpdatePasswordViewController.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/16.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import UIKit
import RxCocoa
import RxSwift
import Toaster

class UpdatePasswordViewController: BaseViewController {

    
    @IBOutlet var currentPasswordTextField : UITextField!
    @IBOutlet var newPasswordTextField : UITextField!
    @IBOutlet var confirmPasswordTextField : UITextField!
    @IBOutlet var currentPasswordHintLabel : UILabel!
    @IBOutlet var newPasswordHintLabel : UILabel!
    @IBOutlet var confirmPasswordHintLabel : UILabel!
    @IBOutlet var submitButton : UIButton!
    @IBOutlet weak var keyboard:NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "修改密码"
        submitButton.isEnabled = false
        bindUI()
        setupDismissTap()
        setupKeyboard()
        // Do any additional setup after loading the view.
    }
    
    private func setupKeyboard(){
        if Views.isIPhoneSE() {
        setupKeyboard(keyboard , height: -80)
        }
    }
    
    private func bindUI(){
        
        let isCurrentPasswordValid = currentPasswordTextField.rx.text.map({$0 ?? ""})
            .map { (str) -> (Bool,String) in
                return (RegexHelper.match(pattern:.password,input:str),str)
        }
        let isNewPasswordValid = newPasswordTextField.rx.text.map({$0 ?? ""})
            .map { (str) -> (Bool,String) in
                return (RegexHelper.match(pattern:.password,input:str),str)
        }
        let isConfirmPasswordValid = confirmPasswordTextField.rx.text.map({$0 ?? ""})
            .map { (str) -> (Bool,String) in
                return (RegexHelper.match(pattern:.password,input:str),str)
        }
        let isPasswordConsistent = Observable.combineLatest([isNewPasswordValid,isConfirmPasswordValid]).map { (isvalid) -> Bool in
            return isvalid[0].1 == isvalid[1].1
        }
        isCurrentPasswordValid.skip(1).subscribeSuccess {[weak self] (isValid,str) in
            guard let weakSelf = self else { return }
            weakSelf.currentPasswordHintLabel.isHidden = isValid
            weakSelf.currentPasswordHintLabel.text = str.count > 0 ? Constants.Tiger_Text_Cell_ErrorUserPasswordNoCurrect: Constants.Tiger_Text_Cell_ErrorUserRecheckPWNoCurrect
            }.disposed(by: disposeBag)
        isNewPasswordValid.skip(1).subscribeSuccess {[weak self] (isValid,str) in
            guard let weakSelf = self else { return }
            weakSelf.newPasswordHintLabel.isHidden = isValid
            weakSelf.newPasswordHintLabel.text = str.count > 0 ? Constants.Tiger_Text_Cell_ErrorUserPasswordNoCurrect: Constants.Tiger_Text_Cell_ErrorUserRecheckPWNoCurrect
            }.disposed(by: disposeBag)
        
        isConfirmPasswordValid.withLatestFrom(isNewPasswordValid){[$0,$1]}.skip(1).subscribeSuccess {[weak self] (isValid) in
            guard let weakSelf = self else { return }
            let confirmPassword = isValid[0]
            let newPassword = isValid[1]
            let isSamePassword = newPassword.1 == confirmPassword.1
            if confirmPassword.0 {
                weakSelf.confirmPasswordHintLabel.isHidden = isSamePassword
                weakSelf.confirmPasswordHintLabel.text = isSamePassword ? weakSelf.confirmPasswordHintLabel.text : Constants.Tiger_ForgatPW_Cell_Stet3_PWNoCurrect
            } else {
                weakSelf.confirmPasswordHintLabel.isHidden = confirmPassword.0
                weakSelf.confirmPasswordHintLabel.text = confirmPassword.1.count > 0 ? Constants.Tiger_Text_Cell_ErrorUserPasswordNoCurrect: Constants.Tiger_Text_Cell_ErrorUserRecheckPWNoCurrect
            }
            }.disposed(by: disposeBag)
        
        let isRegexPass = Observable.combineLatest([isCurrentPasswordValid,isNewPasswordValid,isConfirmPasswordValid]).map { (isvalids) -> Bool in
            isvalids.reduce(true, { (result, arg1) -> Bool in
                let (isValid, _) = arg1
                return result && isValid
            })
        }
        Observable.combineLatest(isRegexPass,isPasswordConsistent){ $0 && $1}.subscribeSuccess({[weak self] (isValid) in
            self?.submitButton.isEnabled = isValid
        })
            .disposed(by: disposeBag)
        
        
        submitButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let weakSelf = self ,
                let oldPassword = weakSelf.currentPasswordTextField.text,
                let newPassword = weakSelf.confirmPasswordTextField.text,
                let agency = AgencyMemberDto.share else {return}
            Beans.agencyAdminService.agencyUserChangePsw(agencyId: agency.AgencyId, password: oldPassword, newPassword: newPassword)
                .subscribeSuccess({[weak self] (memberPasswordSetDto) in
                    guard let weakSelf = self else { return }
                    if memberPasswordSetDto.result {
                        Toast.show(msg: "密码修改成功")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            _ = weakSelf.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        Toast.show(msg: "密码修改失敗")
                    }
            }).disposed(by: weakSelf.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    
    func clearAllTextfield(){
        currentPasswordTextField.text = ""
        newPasswordTextField.text = ""
        confirmPasswordTextField.text = ""
        currentPasswordHintLabel.isHidden = true
        newPasswordHintLabel.isHidden = true
        confirmPasswordHintLabel.isHidden = true
        
    }
    
    private func isPasswordLenthValid(text:String)->Bool {
        let count = text.count
        if (count > 20 || count < 8) {
            return false
        }
        return true
    }
    
    private func hintText(passwords:[String]) -> String {
        let oldPassWord = passwords.first ?? ""
        let newPassWord = passwords.last ?? ""
        
        if isPasswordLenthValid(text:newPassWord) {
            return oldPassWord == newPassWord ? "" : "两次输入密码不一致！"
        } else {
            return "请输入新密码"
        }
        
    }

}
