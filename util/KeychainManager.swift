//
//  KeychainManager.swift
//  agency.ios
//
//  Created by Victor on 2019/4/23.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import KeychainSwift

let Keychain_FingerID_Key = "finger_id"

class KeychainManager {
    
    static let share = KeychainManager()
    
    func save(id: String) -> Bool {
        return KeychainSwift().set(id, forKey: Keychain_FingerID_Key)
    }
    
    func get() -> String? {
        return KeychainSwift().get(Keychain_FingerID_Key)
    }
    
    
    func getFingerID() -> String? {
        
        if let fingerID = get() {
            Log.i("has fingerID: \(fingerID)")
            return fingerID
        } else {
            let uuid = UUID().uuidString
            Log.i("no fingerID create one")
            if save(id: uuid) {
                Log.i("saveo fingerID: \(uuid)")
                return uuid
            } else {
                Log.i("create fingerID fail.")
                return nil
            }
        }
    }
}
