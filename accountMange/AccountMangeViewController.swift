//
//  AccountMangeViewController.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/16.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit

class AccountMangeViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource {
    
    enum MangeType :Int,CaseIterable {
        case password , phone
        
        var title:String  {
            switch  self {
            case .password:
                return "修改密码"
            case .phone:
                return "修改手机号"
            }
        }
    }
    @IBOutlet weak var tableview:UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "帐号设置"
        view.backgroundColor = Themes.sectionBackground
        setupTableView()
    }
  
    private func setupTableView(){
        tableview.dataSource = self
        tableview.delegate = self
        tableview.registerXibCell(type: AccountMangeTableViewCell.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MangeType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = MangeType(rawValue: indexPath.row) else {return UITableViewCell()}
            let cell = tableview.dequeueCell(type: AccountMangeTableViewCell.self, indexPath: indexPath)
            cell.setTitle(type.title)
        switch type {
        case .phone:
            break
        default:
            cell.addBottomSeparator(color: Themes.sectionBackground)
        }
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = MangeType(rawValue: indexPath.row) else { return }
        switch type {
        case .password:
            let newVC = UpdatePasswordViewController.loadNib()
            show(newVC, sender: nil)
        case .phone:
            let newVC = UpdatePhoneViewController.loadNib()
            show(newVC, sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}
