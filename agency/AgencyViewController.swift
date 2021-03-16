//
//  AgencyViewController.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/10.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import Toaster
typealias AgencySectionCellType = (section:AgencySectionType , cell:AgencySectionType.CellType)
enum AgencySectionType:Int,CaseIterable{
    case walletInfoAndperforamance, delegateReport , general , accountManage , logout , none
    static func get(indexPath:IndexPath) -> AgencySectionCellType {
        let section = AgencySectionType(rawValue: indexPath.section)
        var cell:CellType = .none
        guard let agencySection = section else { return (.none,cell) }
        switch agencySection {
        case .walletInfoAndperforamance:
            switch indexPath.row {
            case 0:
                cell = .walletInfo
            case 1:
                cell = .perforamance
            default:
                break
            }
        case .general:
            switch indexPath.row {
            case 0:
                cell = .news
            case 1:
                cell = .promot
            case 2:
                cell = .delegateWallet
            case 3:
                cell = .secondary
            default:
                break
            }
        case .accountManage:
            switch indexPath.row {
            case 0:
                cell = .account
            default:
                break
            }
        case .logout:
            switch indexPath.row {
            case 0:
                cell = .logout
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
        case .walletInfoAndperforamance:
            return 2
        case .general:
            return 4
        default:
            return 1
        }
    }
    
    static func cellHeight(indexPath:IndexPath) -> CGFloat {
       let type = get(indexPath: indexPath)
        switch type.section {
        case .walletInfoAndperforamance:
            switch type.cell {
            case .walletInfo:
                return 220
            case .perforamance:
                return UITableView.automaticDimension
            default:
                return 0
            }
        case .delegateReport:
            return UITableView.automaticDimension
        case .general:
            return 45
        case .accountManage:
            return 45
        case .logout:
            return 45
        default:
            return 0
        }
    }
    
    enum CellType:String{
        case walletInfo = "walletInfo" , perforamance = "perforamance",
         news = "最新公告", promot = "推广连结", delegateWallet = "代理钱包",secondary = "二级管理",
         account = "帐号设置",
         logout = "登 出",
         none = "未設置"
        var icon:UIImage? {
            switch  self {
            case .news:
                return UIImage(named: "icon-news")
            case .promot:
                return UIImage(named: "icon-promot")
            case .delegateWallet:
                return UIImage(named: "icon-wallet")
            case .secondary:
                return UIImage(named: "icon-secondary")
            case .account:
                return UIImage(named: "icon-account")
            default:
                return nil
            }
        }
    }

}


class AgencyViewController: BaseViewController, DelegateTableViewCellDelegate, PerformanceTableViewCellDelegate
{
    
    @IBOutlet var mainTableview: UITableView!
    // 代理錢包參數
    var totalCashString : String? = ""
    private var _agencyMemberDto : AgencyMemberDto?
    var agencyMemberDto : AgencyMemberDto?
    {
        get{
            return _agencyMemberDto
        }
        set{
            _agencyMemberDto = newValue
            fetchDataAfterLogin()
        }
    }
    // 回傳DTO
    var userWalletInfoDto : ResponseDto<[UserWalletInfoDataDto],UserWalletInfoOtherDto>?
    
    var cashierChannelDto : [AgencyCashierChannelDataDto]?
   
    
    var userBankListDataDto : Dictionary<String , AgencyGetUserBankListDataDto>?
    var agencyBankListDataDto : [AgencyBankListDto]?
    
    private var newsListDto = [NewsDto]()
    // 存款成功回傳資料
    var hgServiceNetBankSuccessData : AGencyPaymentPayBankDto!
    var hgServiceWeChatSuccessData : AgencyPaymentPayThirdpayDto!
    var hgServiceUnionQRCodeSuccessData : AgencyPaymentPayThirdpayDto!
    
    static func loadViewFromNib() -> AgencyViewController {
        let vc = AgencyViewController.loadNib()
        vc.agencyMemberDto = AgencyMemberDto.share
        return vc
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMember), name: NotifyConstant.agencyMemberUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NotifyConstant.agencyVCRelaodData, object: nil)
        isShowBottomViewCopyRightView = true
        setupTableView()
        mainTableViewRegisterCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func updateWallet(_ wallet: ResponseDto<[UserWalletInfoDataDto], UserWalletInfoOtherDto>) {
        userWalletInfoDto = wallet
        mainTableview.reloadData()
    }
    
    @objc private func updateMember(_ notification: Notification){
        if let memberDto = notification.object as? AgencyMemberDto {
            agencyMemberDto = memberDto
            mainTableview.reloadData()
        }
    }
    @objc private func reloadData(_ notification: Notification){
            mainTableview.reloadData()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func fetchDataAfterLogin()
    {
        getUserWalletInfo()
        getUserBankList()
        getCashierChannel()
        getAgencyBankList()
        getNewsList()
    }
    func getAgencyBankList()
    {
        Log.i("[NetCall]-撈取代理的銀行 資料")
        Beans.agencyPaymentService.getAgencyBankList(agencyMemberDto: agencyMemberDto!).subscribeSuccess { data in
            self.agencyBankListDataDto = data
            Log.i("[NetCall]-撈取代理的銀行 成功 : \(data)")
            OperationQueue.main.addOperation {
                
            }
            }.disposed(by: disposeBag)
    }
    func getUserBankList()
    {
        Log.i("[NetCall]-撈取使用者設定的銀行 資料")
        Beans.agencyPaymentService.getUserBankList().subscribeSuccess { dict in
            self.userBankListDataDto = dict
            Log.i("[NetCall]-撈取使用者設定的銀行 成功 : \(dict)")
            OperationQueue.main.addOperation {
                
            }
        }.disposed(by: disposeBag)
    }
    func getCashierChannel()
    {
        Log.i("[NetCall]-撈取銀行頻道 資料")
        Beans.agencyPaymentService.getCashierChannel().subscribeSuccess { (CashierChannelDto) in
            self.cashierChannelDto = CashierChannelDto
            Log.i("[NetCall]-撈取銀行頻道 成功 : \(CashierChannelDto)")
            OperationQueue.main.addOperation {
                
            }
        }.disposed(by: disposeBag)
    }
    func getUserWalletInfo()
    {
        Beans.agencyWalletService.userWalletInfo(agencyMemberDto: agencyMemberDto!).subscribeSuccess { (UserWalletInfoDto) in
            self.userWalletInfoDto = UserWalletInfoDto
            OperationQueue.main.addOperation {
                self.mainTableview.reloadData()
            }
            Log.i("UserWalletInfoDto : \(UserWalletInfoDto)")
        }.disposed(by: disposeBag)
    }
    // 
    private func getNewsList(){
        Beans.agencyAdminService.getAgencyNewsList().subscribeSuccess {[weak self] (newsDtos) in
            guard let weakSelf = self else { return }
            weakSelf.newsListDto = newsDtos
            weakSelf.mainTableview.reloadRows(at: [IndexPath(item: 0, section: 3)], with: .automatic)
        }.disposed(by: disposeBag)
    }
    
    
    func setupTableView()
    {
        mainTableview.delegate = self
        mainTableview.dataSource = self
        mainTableview.separatorStyle = .none
        mainTableview.snp.makeConstraints { (maker) in
            maker.leading.trailing.top.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-68 - Views.bottomOffset)
        }
    }
    func mainTableViewRegisterCell()
    {
        mainTableview.registerXibCell(type: PersonalInfoCell.self)
        mainTableview.registerXibCell(type: PerformanceTableViewCell.self)
        mainTableview.registerXibCell(type: DelegateTableViewCell.self)
        mainTableview.registerXibCell(type: SubTableViewCell.self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "代理後台"
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 21)]
    }

    // MARK: - Cells delegate
    func memberListButtonPressed() {
        // 會員列表
        guard let agencyId = self.agencyMemberDto?.AgencyId else { return }
        let  memberReportVC = MemberReportViewController.loadNib()
        memberReportVC.agencyId = agencyId
        memberReportVC.memberListType = .all
        memberReportVC.searchCond = nil
        memberReportVC.getMemberList()
        self.show(memberReportVC, sender: nil)
    }
    
    func finacialReportButtonPressed() {
        guard let agencyId = self.agencyMemberDto?.AgencyId else { return }
        let financialReportVC = FinancialReportViewController.loadNib()
        financialReportVC.reportType = .finance
        financialReportVC.agencyId = agencyId
        financialReportVC.getData()
        self.show(financialReportVC, sender: nil)

    }
    
    func commissionButtonPressed() {
        guard let agencyId = self.agencyMemberDto?.AgencyId else { return }
        let financialReportVC = FinancialReportViewController.loadNib()
        financialReportVC.reportType = .commission
        financialReportVC.agencyId = agencyId
        financialReportVC.getData()
        self.show(financialReportVC, sender: nil)
    }
  
    func performanceCellDidTap(_ action: PerformanceType) {
        switch action {
        case .profit:
            showFinancialReportViewController(reportType: .finance)
        case .commission:
            showFinancialReportViewController(reportType: .commission)
        case .activeMember:
            showMemberReportViewController(searchCond: 1, lstType: .active)
        case .newMember:
            showMemberReportViewController(searchCond: 2, lstType: .newRegist)
        }
    }
    
    func showMemberReportViewController(searchCond: Int? = nil, lstType: MemberListType) {
        guard let agencyId = self.agencyMemberDto?.AgencyId else { return }
        let  memberReportVC = MemberReportViewController.loadNib()
        memberReportVC.memberListType = lstType
        memberReportVC.agencyId = agencyId
        memberReportVC.searchCond = searchCond
        memberReportVC.getMemberList()
        self.show(memberReportVC, sender: nil)
    }
    
    func showFinancialReportViewController(reportType: ReportType) {
        guard let agencyId = self.agencyMemberDto?.AgencyId else { return }
        let financialReportVC = FinancialReportViewController.loadNib()
        financialReportVC.reportType = reportType
        financialReportVC.agencyId = agencyId
        financialReportVC.getData()
        self.show(financialReportVC, sender: nil)
    }
    @objc func longPressed()
    {
        setupActionsheet()
    }
    func setupActionsheet()
    {
        let alertSheet = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
        alertSheet.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        alertSheet.popoverPresentationController?.sourceView = self.view
        alertSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        alertSheet.addAction(cancelAction)
        
        var archiveProAction : UIAlertAction!
        archiveProAction = UIAlertAction(title:"正式機", style: UIAlertAction.Style.default, handler:
            {
                action in
                UserDefaults.Verification.set(value: "", forKey: .jwt_token)
                UserDefaults.Verification.set(value:true , forKey: .agency_pro_tag)
                UserDefaults.Verification.set(value:false , forKey: .agency_stage_tag)
                exit(0)
        })
        var archiveDevAction : UIAlertAction!
        archiveDevAction = UIAlertAction(title:"測試機", style: UIAlertAction.Style.default, handler:
            {
                action in
                UserDefaults.Verification.set(value: "", forKey: .jwt_token)
                UserDefaults.Verification.set(value:false , forKey: .agency_pro_tag)
                UserDefaults.Verification.set(value:false , forKey: .agency_stage_tag)
                exit(0)
        })
        var archiveStageAction : UIAlertAction!
        archiveStageAction = UIAlertAction(title:"Stage機", style: UIAlertAction.Style.default, handler:
            {
                action in
                UserDefaults.Verification.set(value: "", forKey: .jwt_token)
                UserDefaults.Verification.set(value:false , forKey: .agency_pro_tag)
                UserDefaults.Verification.set(value:true , forKey: .agency_stage_tag)
                exit(0)
        })
        alertSheet.addAction(archiveProAction)
        alertSheet.addAction(archiveDevAction)
        alertSheet.addAction(archiveStageAction)
        
        present(alertSheet, animated: true, completion: nil)
    }
}
// MARK: - TableView delegate datasource
extension AgencyViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if tableView == mainTableview
        {
            return 20
        }else
        {
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == mainTableview
        {
            let footerView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: mainTableview.frame.size.width, height: 20))
            footerView.backgroundColor = Themes.sectionBackground
            if section == 4
            {
                let versionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
                versionLabel.center = footerView.center
                let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                versionLabel.text = "版本号 " + versionString!
                versionLabel.textColor = UIColor.darkGray
                versionLabel.textAlignment = .center
                versionLabel.font = UIFont.boldSystemFont(ofSize: 12)
                let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
                footerView.addGestureRecognizer(longPressedGesture)
                footerView.addSubview(versionLabel)
                footerView.isUserInteractionEnabled = true
                return footerView
            }else
            {
                return footerView
            }
        }else
        {
            return nil
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      let type = AgencySectionType(rawValue: section)
        return type?.numberOfCell ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AgencySectionType.cellHeight(indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let type = AgencySectionType.get(indexPath: indexPath)
        switch type.section{
        case .walletInfoAndperforamance:
            switch type.cell {
                case .walletInfo:
                    let personalInfoCell = tableView.dequeueCell(type: PersonalInfoCell.self, indexPath: indexPath)
                    personalInfoCell.agencyMemberDto = agencyMemberDto
                    personalInfoCell.infoData = userWalletInfoDto
                    totalCashString = personalInfoCell.cashLabel.text
                    
                    return personalInfoCell
                case .perforamance:
                    
                    let performanceCell = tableView.dequeueCell(type: PerformanceTableViewCell.self, indexPath: indexPath)
                    performanceCell.setData(userWalletInfoDto: userWalletInfoDto?.data.first)
                    performanceCell.delegate = self
                    return performanceCell
                default:
                    break
            }
        case .delegateReport:
            let delegateCell = tableView.dequeueCell(type: DelegateTableViewCell.self, indexPath: indexPath)
            delegateCell.delegate = self
            return delegateCell
        case .general:
            let generalCell = tableView.dequeueCell(type: SubTableViewCell.self, indexPath: indexPath)
            generalCell.configureCell(title: type.cell.rawValue, icon: type.cell.icon, center: nil)
            generalCell.accessoryType = .disclosureIndicator
            switch type.cell {
            case .news:
                let news = UserDefaults.readNews.stringArray(forKey: .sn)
                let unread = newsListDto.filter { (newsDto) -> Bool in
                  return  !news.contains(newsDto.Sn)
                }.count
                generalCell.configureCell(unread: unread)
            default:
                break
            }
            return generalCell
        case .accountManage:
            let accountManageCell = tableView.dequeueCell(type: SubTableViewCell.self, indexPath: indexPath)
            accountManageCell.configureCell(title: type.cell.rawValue, icon: type.cell.icon, center: nil)
            accountManageCell.accessoryType = .disclosureIndicator
            return accountManageCell
        case .logout:
            let subCell = tableView.dequeueCell(type: SubTableViewCell.self, indexPath: indexPath)
            subCell.configureCell(title: type.cell.rawValue, icon: type.cell.icon, center: true)
            subCell.accessoryType = .none
            subCell.configureCell(unread: 0)
            return subCell
        default:
            break
        }
        return UITableViewCell()
    }
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let  agencyType = AgencySectionType.get(indexPath: indexPath)
        switch agencyType.section {
        case .general:
            switch agencyType.cell {
            case .news:
                let newVC = NewsViewController.loadViewFromNib(newsDtos: newsListDto)
                show(newVC, sender: nil)
            case .promot:
                guard let agencyMemberDto = agencyMemberDto else { return }
                let newVC = PromotViewController.loadViewFromNib(agencyMemberDto: agencyMemberDto)
                show(newVC, sender: nil)
            case .delegateWallet:
                guard let agencyMemberDto = agencyMemberDto else { return }
                let newVC = DelegateWalletViewController.loadViewFromNib(agencyMemberDto: agencyMemberDto ,singleSection: false)
                newVC.cashierChannelDto = cashierChannelDto
                newVC.userBankListAtDelegateW = userBankListDataDto
                newVC.agencyBankListDataDto = agencyBankListDataDto
                show(newVC, sender: nil)
            case .secondary:
                guard let agencyMemberDto = agencyMemberDto else { return }
                let newVC = SecondaryMangeViewController.loadViewFromNib(agencyId: agencyMemberDto.AgencyId)
                show(newVC, sender: nil)
            default:
                break
            }
        case .accountManage:
               let newVC = AccountMangeViewController.loadNib()
               show(newVC, sender: nil)
        case .logout:
            UserDefaults.Verification.set(value: "", forKey: .jwt_token)
            self.present(AgencyNavigationController(rootViewController:LoginViewController.loadViewFromNib()), animated: true, completion: nil)
        default:
            break
        }
        Log.i("\(agencyType.cell.rawValue)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
