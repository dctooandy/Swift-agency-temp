//
//  AccessTokenAdapter.swift
//  Pre18tg
//
//  Created by Andy Chen on 2019/4/9.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJWT

class AccessTokenAdapter: RequestAdapter {
    private var accessToken: String {
       let currentJWT = UserDefaults.Verification.string(forKey: .jwt_token)
         if !(currentJWT.isEmpty)
        {
            return currentJWT
        }else
        {
            let alg = JWTAlgorithm.hs256(Constants.Tiger_SecretKey)
            let payload = JWTPayload()
            //        payload.expiration = 515616187993
            let jwtWithKeyId = JWT.init(payload: payload, algorithm: alg)
            Log.v("raw \(String(describing: jwtWithKeyId!.rawString))")
            return jwtWithKeyId!.rawString
        }
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        Log.v(accessToken)
        urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField:"Accept")
        urlRequest.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}
