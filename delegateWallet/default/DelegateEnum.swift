//
//  DelegateEnum.swift
//  agency.ios
//
//  Created by AndyChen on 2019/4/18.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
enum CashChannelMode : Int
{
    case FastChannel = 1
    case SilverChannel
    case AlipayChannel
    case UnionChannel
    case NetBankChannel
    case WeChatChannel
    case UnionQRCodeChannel
    case None
}
enum AddBankInfoMode
{
    case SelectBankOption
    case ProvinceOption
    case CityOption
    case StateOption
    case None
}
