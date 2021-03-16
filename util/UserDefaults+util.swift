//
//  UserDefaults+util.swift
//  Pre18tg
//
//  Created by Andy Chen on 2019/4/9.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation


protocol UserDefaultsSettable
{
    associatedtype defaultKeys: RawRepresentable
}

extension UserDefaults
{
    // 驗證用
    struct Verification: UserDefaultsSettable {
        enum defaultKeys: String {
            case status
            case data
            case jwt_token
            case message
            case other
            case error_message
            case error_code
            case agency_pro_tag
            case agency_stage_tag
        }
       
    }
    
    // 登录信息
    struct LoginInfo: UserDefaultsSettable {
        enum defaultKeys: String {
            case token
            case userId
        }
    }
    
    // 登录信息
    struct readNews: UserDefaultsSettable {
        enum defaultKeys: String {
            case sn
        }
    }
}

extension UserDefaultsSettable where defaultKeys.RawValue==String {
    static func set(value: String?, forKey key: defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    static func set(value: [String]?, forKey key: defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    static func set(value: Bool, forKey key: defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    
    static func string(forKey key: defaultKeys) -> String {
        let aKey = key.rawValue
        if let value = UserDefaults.standard.string(forKey: aKey) {
            return value
        }
        return ""
    }
    static func bool(forKey key: defaultKeys) -> Bool {
        let aKey = key.rawValue
        if let value = UserDefaults.standard.value(forKey: aKey) as? Bool {
            return value
        }
        return false
    }
    
    static func stringArray(forKey key: defaultKeys) -> [String] {
        let aKey = key.rawValue
        if let value = UserDefaults.standard.stringArray(forKey: aKey) {
            return value
        }
        return [String]()
    }
}
