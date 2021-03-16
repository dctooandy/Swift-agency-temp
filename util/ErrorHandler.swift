//
//  ErrorHandler.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/12.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import Toaster
class ErrorHandler {
    
    static func show(error:Error) {
        if let error = error as? ApiServiceError {
            switch error {
            case .domainError(let (_,msg)):
                Log.e(msg ?? " no error message")
                showAlert(title: "错误讯息", message: msg ?? "")
            case .networkError(let msg):
                Log.e(msg ?? " no error message")
                showAlert(title: "错误讯息", message: msg ?? "")
            case .unknownError(let msg):
                Log.e(msg ?? " no error message")
                showAlert(title: "错误讯息", message: msg ?? "")
            case .tokenError:
                Log.e("tokenExpireError")
                Toast.show(msg:"tokenExpireError")
            case .tokenExpire:
                showAlert(title: "错误讯息", message: "连线逾时请重新登入")
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                break
            }
        } else {
            Toast.show(msg:"unDefine error type")
        }
        
    }
    
    static func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(okAction)
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
}
