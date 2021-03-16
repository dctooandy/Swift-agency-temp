//
// Created by liq on 2018/6/11.
// Copyright (c) 2018 Pomelo Network PTE. LTD. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import Toaster

extension DataRequest {
    func responseCustomModel<T:Codable,U:Codable>(_ type:T.Type,
                                        other:U.Type,
                                        onData:((ResponseDto<T,U>) -> Void)? = nil,
                                        onError:((ApiServiceError) -> Void)? = nil) -> Self {
        
        return responseJSON { response in
            Log.v("\(String(describing: response.request?.url))")
            guard let data = response.data else {
                Log.errorAndCrash("response no data")
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            if let responseString = String(data: data, encoding: .utf8)
            {
                if let dict = self.convertToDictionary(text: responseString), let status = dict["status"] as? Int
                {
                    
//                    Log.v("Response dictionary \(dict as AnyObject)")
                    if status == 0 {
                        do {
                            let msg = try decoder.decode(ResponseErrorDto.self, from:data)
                            if msg.error_code == "10003" ||  msg.error_code == "10007"{
                                UserDefaults.Verification.set(value: "", forKey: .jwt_token)
                                onError?(ApiServiceError.tokenError)
                            }else {
                                onError?(ApiServiceError.domainError(msg.error_code,msg.error_message))
                            }
                            return
                        } catch (let error) {
                            Log.e(error)
                            Log.errorAndCrash("Decode error: \(error.localizedDescription)")
                        }
                    }
                    if self.isNeedCheckToken(url:response.request?.url) {
                        if let jwtTokenDict = (dict["data"] as? Dictionary<String , Any>) ,
                            (jwtTokenDict["jwt_token"] != nil)
                        {
                            Log.v("是Dict,可能過期")
                            UserDefaults.Verification.set(value: "", forKey:UserDefaults.Verification.defaultKeys.jwt_token)
                            onError?(ApiServiceError.tokenExpire)
                            return
                        }
                    }                
                }
            }
            if let statusCode = response.response?.statusCode {
                
                switch statusCode {
                case 200..<400:
                    do {
                        let results = try decoder.decode(ResponseDto<T,U>.self, from:data)
                        onData?(results)
                    } catch DecodingError.dataCorrupted(let context)
                    {
                        Log.errorAndCrash("Type '\(type)' dataCorrupted:", context.debugDescription)
                    } catch DecodingError.keyNotFound(let key, let context)
                    {
                        Log.errorAndCrash("Type '\(key)' keyNotFound:", context.debugDescription)
                    } catch DecodingError.typeMismatch(let type, let context)
                    {
                        Log.errorAndCrash("Type '\(type)' mismatch:", context.debugDescription)
                    } catch DecodingError.valueNotFound(let value, let context)
                    {
                        Log.errorAndCrash("Type '\(value)' valueNotFound:", context.debugDescription)
                    }
                    catch
                    {
                        Log.errorAndCrash(error.localizedDescription)
                    }
                case 400..<500:
                    do {
                        let msg = try decoder.decode(ResponseErrorDto.self, from:data)
                        onError?(ApiServiceError.domainError(nil,msg.error_message))
                    } catch (let error) {
                        Log.errorAndCrash("Decode error: \(error.localizedDescription)")
                    }
                case 500..<600:
                    do {
                        let msg = try decoder.decode(ResponseErrorDto.self, from:data)
                        onError?(ApiServiceError.networkError(msg.error_message))
                    } catch (let error) {
//                        let data = try? JSONSerialization.jsonObject(with:data, options:.allowFragments)
//                        print(data)
                        onError?(ApiServiceError.unknownError(error.localizedDescription))
                    }
                default:
                    onError?(ApiServiceError.unknownError("unDefine status code error"))
                }
            }
            if let error = response.error {
//                let data = try? JSONSerialization.jsonObject(with:data, options:.allowFragments)
//                print(data)
                onError?(ApiServiceError.unknownError(error.localizedDescription))
            }
            
        }
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]?
    {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                Log.e(error.localizedDescription)
            }
        }
        return nil
    }
    
    func isNeedCheckToken(url:URL?) -> Bool {
        guard let path = url?.absoluteString.split(separator: "/").last else {return false}
        let urlString = String(path)
        for url in Constants.bypassUrl {
            if url.contains(urlString) {
                return false
            }
        }
        return true
    }
    func responseCustomJsonModel<T:Codable>(_ type:T.Type,
                                            onData:((T) -> Void)? = nil,
                                            onError:((ApiServiceError) -> Void)? = nil) -> Self {
        
        return responseJSON { response in
            Log.v("\(String(describing: response.request?.url))")
            guard let data = response.data else {
                Log.errorAndCrash("response no data")
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            if let responseString = String(data: data, encoding: .utf8)
            {
                if let dict = self.convertToDictionary(text: responseString), let status = dict["status"] as? Int
                {
                    if status == 0 {
                        do {
                            let msg = try decoder.decode(ResponseErrorDto.self, from:data)
                            if msg.error_code == "10003" ||  msg.error_code == "10007"{
                                UserDefaults.Verification.set(value: "", forKey: .jwt_token)
                                onError?(ApiServiceError.tokenError)
                            }else {
                                onError?(ApiServiceError.domainError(msg.error_code,msg.error_message))
                            }
                            return
                        } catch (let error) {
                            Log.e(error)
                            Log.errorAndCrash("Decode error: \(error.localizedDescription)")
                        }
                    }
                    if self.isNeedCheckToken(url:response.request?.url) {
                        if let jwtTokenDict = (dict["data"] as? Dictionary<String , Any>) ,
                            (jwtTokenDict["jwt_token"] != nil)
                        {
                            Log.v("是Dict,可能過期")
                            UserDefaults.Verification.set(value: "", forKey:UserDefaults.Verification.defaultKeys.jwt_token)
                            onError?(ApiServiceError.tokenError)
                            return
                        }
                    }
                }
            }
            if let statusCode = response.response?.statusCode {
                
                switch statusCode {
                case 200..<400:
                    do {
                        let results = try decoder.decode((T).self, from:data)
                        onData?(results)
                    } catch DecodingError.dataCorrupted(let context)
                    {
                        Log.errorAndCrash("Type '\(type)' dataCorrupted:", context.debugDescription)
                    } catch DecodingError.keyNotFound(let key, let context)
                    {
                        Log.errorAndCrash("Type '\(key)' keyNotFound:", context.debugDescription)
                    } catch DecodingError.typeMismatch(let type, let context)
                    {
                        Log.errorAndCrash("Type '\(type)' mismatch:", context.debugDescription)
                    } catch DecodingError.valueNotFound(let value, let context)
                    {
                        Log.errorAndCrash("Type '\(value)' valueNotFound:", context.debugDescription)
                    }
                    catch
                    {
                        Log.errorAndCrash(error.localizedDescription)
                    }
                case 400..<500:
                    do {
                        let msg = try decoder.decode(ResponseErrorDto.self, from:data)
                        onError?(ApiServiceError.domainError(nil,msg.error_message))
                    } catch (let error) {
                        Log.errorAndCrash("Decode error: \(error.localizedDescription)")
                    }
                case 500..<600:
                    do {
                        let msg = try decoder.decode(ResponseErrorDto.self, from:data)
                        onError?(ApiServiceError.networkError(msg.error_message))
                    } catch (let error) {
                        //                        let data = try? JSONSerialization.jsonObject(with:data, options:.allowFragments)
                        //                        print(data)
                        onError?(ApiServiceError.unknownError(error.localizedDescription))
                    }
                default:
                    onError?(ApiServiceError.unknownError("unDefine status code error"))
                }
            }
            if let error = response.error {
                //                let data = try? JSONSerialization.jsonObject(with:data, options:.allowFragments)
                //                print(data)
                onError?(ApiServiceError.unknownError(error.localizedDescription))
            }
            
        }
    }
}
