//
//  DateHelper.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/15.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class DateHelper {
    
    static let share = DateHelper()
    
    private lazy var dateFormater:DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return formater
    }()
    
    private lazy var newsDateFormater:DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy/MM/dd hh:mm"
        return formater
    }()
    
    private let illegalSeconds:Int = 18*365*24*60*60
    
    func checkIsAdult(date:String) -> Bool {
        if let userDate = dateFormater.date(from: date) {
            let illegalDate = Date().addingTimeInterval(TimeInterval(-illegalSeconds))
            return illegalDate > userDate
        }
        return false
    }
    
    func dateString(with date:Date = Date()) -> String {
        return dateFormater.string(from: date)
    }
    
    func aMonthAgo() ->String {
        let aMonthAgo = Date().addingTimeInterval(-30*24*60*60)
        return dateString(with: aMonthAgo)
    }
    
    func transToNewsDateFormat(date:String) -> String {
        let date = dateFormater.date(from: date) ?? Date()
        return newsDateFormater.string(from: date)
    }
    
    
}
