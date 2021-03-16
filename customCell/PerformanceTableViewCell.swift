//
//  PerformanceTableViewCell.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/10.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
protocol PerformanceTableViewCellDelegate: class {
    func performanceCellDidTap(_ action: PerformanceType)
}
enum PerformanceType {
    case profit
    case commission
    case activeMember
    case newMember
}
class PerformanceTableViewCell: BaseTableViewCell {
    
    
    weak var delegate: PerformanceTableViewCellDelegate?
    
    @IBOutlet weak var profitButton: UIButton!
    @IBOutlet weak var commissionButton: UIButton!
    @IBOutlet weak var activeMemberButton: UIButton!
    @IBOutlet weak var newMemberButton: UIButton!
    
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var commissionLabel: UILabel!
    @IBOutlet weak var activeMemberLabel: UILabel!
    @IBOutlet weak var newMemberLabel: UILabel!
    
    @IBOutlet weak var profitImgView: UIImageView!
    @IBOutlet weak var commissionImgView: UIImageView!
    @IBOutlet weak var activeImgView: UIImageView!
    @IBOutlet weak var newMemberImgView: UIImageView!
    
    /// 改个icon颜色
    
    @IBOutlet weak var arrowImgView0: UIImageView!
    @IBOutlet weak var arrowImgView1: UIImageView!
    @IBOutlet weak var arrowImgView2: UIImageView!
    @IBOutlet weak var arrowImgView3: UIImageView!
    
    @IBOutlet weak var upStackView: UIStackView!
    @IBOutlet weak var downStackView: UIStackView!
    
    func setData(userWalletInfoDto: UserWalletInfoDataDto?) {
        guard let dto = userWalletInfoDto else { return }
        profitLabel.text = dto.NetEarnings.numberFormatter(.decimal, 2)
        commissionLabel.text = dto.Commission.numberFormatter(.decimal, 2)
        activeMemberLabel.text = dto.ActiveNum
        newMemberLabel.text = dto.RegistrNum
    }
    
    func bindButton() {
        profitButton.rx.tap
            .subscribeSuccess { [weak self] in
            self?.delegate?.performanceCellDidTap(.profit)
        }.disposed(by: disposeBag)
        
        commissionButton.rx.tap
            .subscribeSuccess { [weak self] in
                self?.delegate?.performanceCellDidTap(.commission)
            }.disposed(by: disposeBag)
        
        activeMemberButton.rx.tap
            .subscribeSuccess { [weak self] in
                self?.delegate?.performanceCellDidTap(.activeMember)
            }.disposed(by: disposeBag)
        
        newMemberButton.rx.tap
            .subscribeSuccess { [weak self] in
                self?.delegate?.performanceCellDidTap(.newMember)
            }.disposed(by: disposeBag)
    }
    
    private func setImageIconColor() {
        profitImgView.setImageTintColor(#colorLiteral(red: 0, green: 0.4844501019, blue: 0.9982939363, alpha: 1))
        commissionImgView.setImageTintColor(#colorLiteral(red: 0, green: 0.4844501019, blue: 0.9982939363, alpha: 1))
        activeImgView.setImageTintColor(#colorLiteral(red: 0, green: 0.4844501019, blue: 0.9982939363, alpha: 1))
        newMemberImgView.setImageTintColor(#colorLiteral(red: 0, green: 0.4844501019, blue: 0.9982939363, alpha: 1))
        arrowImgView0.setImageTintColor(#colorLiteral(red: 0.3746373951, green: 0.3846682012, blue: 0.4015933275, alpha: 1))
        arrowImgView1.setImageTintColor(#colorLiteral(red: 0.3746373951, green: 0.3846682012, blue: 0.4015933275, alpha: 1))
        arrowImgView2.setImageTintColor(#colorLiteral(red: 0.3746373951, green: 0.3846682012, blue: 0.4015933275, alpha: 1))
        arrowImgView3.setImageTintColor(#colorLiteral(red: 0.3746373951, green: 0.3846682012, blue: 0.4015933275, alpha: 1))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bindButton()
        setImageIconColor()
        setupStackView()
    }
    
    private func setupStackView(){
        if Views.isIPhoneSE(){
            upStackView.spacing = 10
            downStackView.spacing = 10
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

