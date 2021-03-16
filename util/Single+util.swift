//
// Created by 黃智聖 on 2018/6/15.
// Copyright (c) 2018 Pomelo Network PTE. LTD. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Toaster

extension PrimitiveSequence where TraitType == SingleTrait {
  public func subscribeSuccess(_ callback:((ElementType) -> Void)? = nil) -> Disposable {
    return subscribe(onSuccess: callback, onError: { error in
        ErrorHandler.show(error: error)
    })
  }
}
