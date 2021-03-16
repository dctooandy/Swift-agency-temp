//
//  DelegateWalletOperationViewController.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/22.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit
import Parchment

class DelegateWalletOperaionViewController:BaseViewController {
    
    private var pagingViewControllers = [UIViewController]()
    
    init(tag:Int = 0 ,cashierChannelDto:[AgencyCashierChannelDataDto] , agencyMemberDto:AgencyMemberDto , userBankListAtDelegateW:Dictionary<String , AgencyGetUserBankListDataDto>, agencyBankListDataDto:[AgencyBankListDto]) {
        super.init()
        title = "代理钱包"
        let saveVC = SaveMoneyViewController()
        saveVC.cashierChannelAtInnerView = cashierChannelDto
        saveVC.agencyMemberDto = agencyMemberDto
        
        let cashVC = CashOutViewController()
        cashVC.agencyMemberDto = agencyMemberDto
        cashVC.userBankListAtInnerView = userBankListAtDelegateW
        cashVC.agencyBankListAtInnerView = agencyBankListDataDto
        let uploadVC = UpLoadViewController()
        uploadVC.agencyMemberDto = agencyMemberDto
        // 會員列表
        uploadVC.agencyId = agencyMemberDto.AgencyId
        
        let pagingViewController = FixedPagingViewController(viewControllers: [
            saveVC,
            cashVC,
            uploadVC
            ])
        pagingViewControllers = [
            saveVC,
            cashVC,
            uploadVC
        ]
        pagingViewController.menuItemSize = PagingMenuItemSize.fixed(width:CGFloat(Views.screenWidth/CGFloat(pagingViewControllers.count)),
                                                                     height:56)
        addChild(pagingViewController)
        pagingViewController.contentInteraction = .none
        view.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pagingViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
            ])
        pagingViewController.dataSource = self
        pagingViewController.select(index:tag)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init error")
    }
    
}

extension DelegateWalletOperaionViewController: PagingViewControllerDataSource {
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController where T : PagingItem, T : Comparable, T : Hashable {
        return pagingViewControllers[index]
    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T where T : PagingItem, T : Comparable, T : Hashable {
        let titleNameArray = ["存款","提款","上分"]
        return PagingIndexItem(index: index, title: titleNameArray[index]) as! T
    }
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int {
        return pagingViewControllers.count
    }
    
}
