//
// Created by liq on 2018/6/12.
// Copyright (c) 2018 Pomelo Network PTE. LTD. All rights reserved.
//

import Foundation
import Toaster
import RxSwift
import RxCocoa

extension Toast {
  static func show(msg:String) {
    let toast = Toast(text: msg)
    toast.show()
  }
  
    static func showSuccess(msg:String) {
        let toast = Toast(text: msg)
        toast.view.textColor = Themes.trueGreenLayerColor
        toast.show()
    }
    
}
