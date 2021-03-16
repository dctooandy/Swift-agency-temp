//
//  CashFlowHeader.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/23.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class CashFlowHeader: UITableViewHeaderFooterView {
    
    private let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private func setupUI(){
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = .white
        titleLabel.textColor = Themes.placeHolderDarkGary
        titleLabel.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.leading.equalTo(20)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHeader(title:String){
        titleLabel.text = title
    }
}
