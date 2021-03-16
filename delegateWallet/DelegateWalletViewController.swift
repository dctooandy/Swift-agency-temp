//
//  DelegateWalletViewController.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/17.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import Parchment
import RxCocoa
import RxSwift
import Toaster
import SnapKit
class DelegateWalletViewController: BaseViewController
{
    var pagingViewControllers = [UIViewController]()
    // 傳遞資料 userBankListDataDto
    var agencyBankListDataDto : [AgencyBankListDto]?
    var userBankListAtDelegateW : Dictionary<String , AgencyGetUserBankListDataDto>?
    var cashierChannelDto : [AgencyCashierChannelDataDto]?
    // 是否Loadmore 模式
    var isLoadMoreAction : Bool! = false
    var cashflowForShowCellCount : Int = 0
    var cashflowForShowCellTotal_rows : Int = 0
    var isSingleSection : Bool = false
    private var isFirstPush = true
    private let bottomFooterViewHeight:CGFloat = 80
    private var dataNumberOfOnePage = 10
    @IBOutlet var delegateWalletTableview: UITableView!
    private var _agencyMemberDto : AgencyMemberDto?
    private var cashLogManager:CashLogManager?
    
    var agencyMemberDto : AgencyMemberDto?
    {
        get{
            return _agencyMemberDto
        }
        set{
            _agencyMemberDto = newValue
            getCashLog(pageNumber: 1, more: false)
        }
    }
    var getCashLogDto : ResponseDto<GetCashLogDataDto,GetCashLogOtherDto>?
    static func loadViewFromNib(agencyMemberDto:AgencyMemberDto , singleSection:Bool) -> DelegateWalletViewController {
        let vc = DelegateWalletViewController.loadNib()
        vc.isSingleSection = singleSection
        vc.agencyMemberDto = agencyMemberDto
        
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstPush = false
        delegateWalletTableViewRegisterCell()
        // Do any additional setup after loading the view.
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if !isFirstPush && !isSingleSection{
            getCashLog(pageNumber: 1, more: false)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSingleSection == true
        {
            title = "钱包纪录"
        }else
        {
            title = "代理钱包"
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func updateWallet(_ wallet: ResponseDto<[UserWalletInfoDataDto], UserWalletInfoOtherDto>) {
        delegateWalletTableview.reloadData()
    }
    
    func delegateWalletTableViewRegisterCell()
    {
        delegateWalletTableview.registerXibCell(type: DelegateHeaderCell.self)
        delegateWalletTableview.registerXibCell(type: CashFlowCell.self)
        delegateWalletTableview.registerXibCell(type: DelegateSubCell.self)
        delegateWalletTableview.registerHeaderFooter(type: CashFlowHeader.self)
        //        delegateWalletTableview.registerXibCell(type: PerformanceTableViewCell.self)
        //        delegateWalletTableview.registerXibCell(type: DelegateTableViewCell.self)
        //        delegateWalletTableview.registerXibCell(type: SubTableViewCell.self)
    }
    func getCashLog(pageNumber: Int , more : Bool)
    {
        dataNumberOfOnePage = isSingleSection == true ? (Views.isIPad() ? 15 : 10) : 5
        let dto = GetCashLogDto(agencyId: self.agencyMemberDto?.AgencyId ?? "", page: pageNumber, pageLimit: dataNumberOfOnePage, more: more)
        Beans.agencyWalletService.getCashLog(getCashLogDto: dto).subscribeSuccess { (getCashLog) in
            Log.i("[NetCallBack]-撈取代理錢包紀錄 成功")
            if self.isLoadMoreAction == true
            {
                Log.i("[NetCallBack] Loadmore撈取")
                self.cashLogManager?.append(getCashLog.data.data_list)
                self.delegateWalletTableview.reloadData()
            }else
            {
                self.cashLogManager = CashLogManager(response: getCashLog)
                self.cashflowForShowCellCount = getCashLog.data.data_list.count
                self.delegateWalletTableview.reloadData()
            }
            self.cashflowForShowCellCount = self.cashLogManager?.getCashLogArrayDataDto.count ?? 0
            self.cashflowForShowCellTotal_rows = Int((getCashLog.data.total_rows)) ?? 0
            }.disposed(by: disposeBag)
    }
    
    func cashflowLoadMoreAction()
    {
        isLoadMoreAction = true
        let currentDataCount = cashflowForShowCellCount
        let pageNumber = (currentDataCount / dataNumberOfOnePage) + 1
        
        getCashLog(pageNumber: pageNumber, more: true)
        
    }
    // 存提上分 動作
    @IBAction func saveCashOutUploadAction(_ sender : UIButton)
    {
        guard let agencyMemberDto = self.agencyMemberDto else {return}
        guard let cashierChannelDto = self.cashierChannelDto,
            let agencyBankListDataDto = self.agencyBankListDataDto,
            let userBankListAtDelegateW = self.userBankListAtDelegateW
            else {
                //retrive data
                Observable.combineLatest(Beans.agencyPaymentService.getUserBankList().asObservable(),Beans.agencyPaymentService.getCashierChannel().asObservable(),Beans.agencyPaymentService.getAgencyBankList(agencyMemberDto: agencyMemberDto).asObservable(), resultSelector: {[weak self] (userBankListDto,cashierChannelDto,agencyBankListDataDto) -> Bool in
                    self?.userBankListAtDelegateW = userBankListDto
                    self?.cashierChannelDto = cashierChannelDto
                    self?.agencyBankListDataDto = agencyBankListDataDto
                    return true
                }).subscribeSuccess {[weak self] (isRetriveDone) in
                    self?.saveCashOutUploadAction(sender)
                    }.disposed(by: disposeBag)
                return
        }
        let newVC = DelegateWalletOperaionViewController(tag: sender.tag, cashierChannelDto: cashierChannelDto, agencyMemberDto: agencyMemberDto, userBankListAtDelegateW: userBankListAtDelegateW, agencyBankListDataDto: agencyBankListDataDto)
        show(newVC, sender: nil)
    }
    private lazy var bottomFooterView:UIView = {
        let footerView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: delegateWalletTableview.frame.size.width, height: bottomFooterViewHeight))
        footerView.backgroundColor = Themes.sectionBackground
        let showMoreBtn = UIButton()
        showMoreBtn.setTitle("查看全部记录", for: .normal)
        showMoreBtn.applyCornerRadius()
        showMoreBtn.backgroundColor = Themes.btnBackgroundBlue
        showMoreBtn.rx.tap.subscribeSuccess {[weak self] (_) in
            guard let weakSelf = self else {return}
            guard let agencyMemberDto = weakSelf.agencyMemberDto else { return }
            let newVC = DelegateWalletViewController.loadViewFromNib(agencyMemberDto: agencyMemberDto ,singleSection: true)
            weakSelf.show(newVC, sender: nil)
            }.disposed(by: disposeBag)
        footerView.addSubview(showMoreBtn)
        showMoreBtn.snp.makeConstraints({ (maker) in
            maker.centerY.equalToSuperview()
            maker.leading.equalTo(20)
            maker.trailing.equalTo(-20)
            maker.height.equalTo(48)
        })
        return footerView
    }()
    
}
extension DelegateWalletViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if section == 0 && !isSingleSection {
            return CGFloat.leastNormalMagnitude
        }
        return 45
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        //Mark bottom footer btn
        if section == 1 && !isSingleSection
        {
            return bottomFooterViewHeight
        }else
        {
            return 20
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 && !isSingleSection
        {
            return bottomFooterView
        }else
        {
            let footerView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: delegateWalletTableview.frame.size.width, height: 20))
            footerView.backgroundColor = Themes.sectionBackground
            return footerView
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let cashManager = cashLogManager else {return  0 }
        if isSingleSection == true
        {
            return cashManager.totalSection
        }else
        {
            return 1 + cashManager.totalSection
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cashManager = cashLogManager else {return  0 }
        if isSingleSection == true
        {
            if section == 0 {
                return cashManager.firstMonthDto?.count ?? 0
            }
            return cashManager.secondMonthDto?.count ?? 0
        }else
        {
            let type = DelegateSectionType(rawValue: section)
            if type == .general
            {
                if let firstMonth = cashManager.firstMonthDto
                {
                    if firstMonth.count > 5
                    {
                        return 5
                    }else
                    {
                        return firstMonth.count
                    }
                }else
                {
                    return 0
                }
            }else
            {
                return type?.numberOfCell ?? 0
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSingleSection == true
        {
            return 80
        }else
        {
            return DelegateSectionType.cellHeight(indexPath: indexPath)
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cashManager = cashLogManager else {return  UITableViewCell() }
        let headerCount = isSingleSection ? 0 : 1
        if section == 0 && !isSingleSection {
            return nil
        }
        let header = delegateWalletTableview.dequeueHeaderFooter(type: CashFlowHeader.self)
        header.configureHeader(title: section == headerCount ? cashManager.fisrtSectionTitle : cashManager.secondSectionTitle)
        return header
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cashManager = cashLogManager else {return  UITableViewCell() }
        if isSingleSection == true
        {
            let subCell = tableView.dequeueCell(type: DelegateSubCell.self, indexPath: indexPath)
            if indexPath.section == 0 {
                if let dto = cashManager.firstMonthDto?[indexPath.row] {
                    subCell.configureCell(cashLog:dto, otherDto: cashManager.getCashLogOtherDto)
                }
            } else {
                if let dto = cashManager.secondMonthDto?[indexPath.row] {
                    subCell.configureCell(cashLog:dto, otherDto: cashManager.getCashLogOtherDto)
                }
            }
            subCell.accessoryType = .disclosureIndicator
            return subCell
        }else
        {
            let  type = DelegateSectionType.get(indexPath: indexPath)
            switch type.section{
            case .header:
                switch type.cell {
                case .header:
                    let walletInfoCell = tableView.dequeueCell(type: DelegateHeaderCell.self, indexPath: indexPath)
                    walletInfoCell.cashLabel.text = UserWalletInfoDataDto.shared?.remaining
                    walletInfoCell.accessoryType = .disclosureIndicator
                    return walletInfoCell
                case .cashflow:
                    let cashFlowCell = tableView.dequeueCell(type: CashFlowCell.self, indexPath: indexPath)
                    cashFlowCell.accessoryType = .none
                    return cashFlowCell
                default:
                    break
                }
                
            case .general:
                let subCell = tableView.dequeueCell(type: DelegateSubCell.self, indexPath: indexPath)
                if let dto = cashManager.firstMonthDto?[indexPath.row] {
                    subCell.configureCell(cashLog:dto, otherDto: cashManager.getCashLogOtherDto)
                }
                subCell.accessoryType = .disclosureIndicator
                return subCell
                
                //        case .accountManage:
                //            let accountManageCell = tableView.dequeueCell(type: SubTableViewCell.self, indexPath: indexPath)
                //            accountManageCell.configureCell(title: type.cell.rawValue, icon: type.cell.icon, center: nil)
                //            accountManageCell.accessoryType = .disclosureIndicator
                //            return accountManageCell
                //        case .logout:
                //            let subCell = tableView.dequeueCell(type: SubTableViewCell.self, indexPath: indexPath)
                //            subCell.configureCell(title: type.cell.rawValue, icon: type.cell.icon, center: true)
                //            subCell.accessoryType = .none
            //            return subCell
            default:
                break
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cashManager = cashLogManager else {return }
        if isSingleSection == true
        {
            if indexPath.section == 0 {
                if let dto = cashManager.firstMonthDto?[indexPath.row] {
                    let newVC = DelegateDetailViewController.loadViewFromNib(getCashLogArrayDataDto: dto)
                    newVC.configureCell(cashLog: dto, otherDto: cashManager.getCashLogOtherDto)
                    show(newVC, sender: nil)
                }
            } else {
                if let dto = cashManager.secondMonthDto?[indexPath.row] {
                    let newVC = DelegateDetailViewController.loadViewFromNib(getCashLogArrayDataDto: dto)
                    newVC.configureCell(cashLog: dto, otherDto: cashManager.getCashLogOtherDto)
                    show(newVC, sender: nil)
                }
            }
        }else
        {
            let  delegateType = DelegateSectionType.get(indexPath: indexPath)
            switch delegateType.section {
            case .header:
                switch delegateType.cell {
                case .header:
                    //                let newVC = NewsViewController.loadNib()
                    //                show(newVC, sender: nil)
                    guard let agencyMemberDto = agencyMemberDto else { return }
                    let newVC = DelegateWalletViewController.loadViewFromNib(agencyMemberDto: agencyMemberDto ,singleSection: true)
                    
                    show(newVC, sender: nil)
                    //            case .promot:
                    //                guard let agencyMemberDto = agencyMemberDto else { return }
                    //                let newVC = PromotViewController.loadViewFromNib(agencyMemberDto: agencyMemberDto)
                    //                show(newVC, sender: nil)
                    //            case .delegateWallet:
                    //                guard let agencyMemberDto = agencyMemberDto else { return }
                    //                let newVC = DelegateWalletViewController.loadViewFromNib(agencyMemberDto: agencyMemberDto)
                    //                newVC.cashString = totalCashString
                    //                show(newVC, sender: nil)
                    //            case .secondary:
                //                break
                default:
                    break
                }
            case .general:
                if let dto = cashManager.firstMonthDto?[indexPath.row] {
                    let newVC = DelegateDetailViewController.loadViewFromNib(getCashLogArrayDataDto: dto)
                    newVC.configureCell(cashLog: dto, otherDto: cashManager.getCashLogOtherDto)
                    show(newVC, sender: nil)
                }
                //            let newVC = AccountMangeViewController.loadNib()
                //            show(newVC, sender: nil)
                //        case .logout:
                //            UserDefaults.Verification.set(value: "", forKey: .jwt_token)
            //            self.present(AgencyNavigationController(rootViewController:LoginViewController.loadViewFromNib()), animated: true, completion: nil)
            default:
                break
            }
            Log.i("\(delegateType.cell.rawValue)")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    {
        if scrollView == delegateWalletTableview
        {
            let offset = scrollView.contentOffset
            let bounds = scrollView.bounds
            let size = scrollView.contentSize
            let inset = scrollView.contentInset
            let y = offset.y + bounds.size.height - inset.bottom
            let h = size.height
            //上拉超過 才做動作
            let reload_distance : CGFloat = 60;
            
            if(y > h + reload_distance)
            {
                if isSingleSection == true, cashflowForShowCellCount != cashflowForShowCellTotal_rows
                {
                    Log.i("Load more")
                    cashflowLoadMoreAction()
                }
            }
        }
    }
}
typealias DelegateSectionCellType = (section:DelegateSectionType , cell:DelegateSectionType.CellType)
enum DelegateSectionType:Int,CaseIterable
{
    case header, general, none
    static func get(indexPath:IndexPath) -> DelegateSectionCellType {
        let section = DelegateSectionType(rawValue: indexPath.section)
        var cell:CellType = .none
        guard let agencySection = section else { return (.none,cell) }
        switch agencySection {
        case .header:
            switch indexPath.row {
            case 0:
                cell = .header
            case 1:
                cell = .cashflow
            default:
                break
            }
            
        case .general:
            switch indexPath.row {
            case 0:
                cell = .generalSave
            default:
                break
            }
        default:
            break
        }
        return (agencySection,cell)
    }
    var numberOfCell:Int {
        switch self {
        case .header:
            return 2
        case .general:
            return 5
        default:
            return 0
        }
    }
    
    static func cellHeight(indexPath:IndexPath) -> CGFloat {
        let type = get(indexPath: indexPath)
        switch type.section {
        case .header:
            switch type.cell {
            case .header:
                return 100
            case .cashflow:
                return 110
            default:
                return 0
            }
        case .general:
            return 80
        default:
            return 0
        }
    }
    
    enum CellType:String{
        case header = "walletInfo", cashflow = "cashflow" , generalSave = "generalSave" , generalCashOut = "generalCashOut" , generalUpload = "generalUpload" , none = "未設置"
        
        var icon:UIImage? {
            switch  self {
            case .header:
                return nil
            case .cashflow:
                return nil
            case .generalSave:
                return #imageLiteral(resourceName: "pic-mb-deposit")
            case .generalCashOut:
                return #imageLiteral(resourceName: "pic-mb-withdrawal")
            case .generalUpload:
                return #imageLiteral(resourceName: "pic-mb-wallet-share")
            case .none:
                
                return nil
            }
        }
    }
    
}
