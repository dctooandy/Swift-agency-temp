//
//  Themes.swift
//  ProjectT
//
//  Created by Andy Chen on 2019/3/21.
//  Copyright © 2019 Andy Chen. All rights reserved.
//
import UIKit
import Foundation

class Themes {
    
    static let textFieldDisableColor = UIColor(rgb: 0xeff2f7)
    static let saveMoneyLayerColor = UIColor(rgb: 0x43959A)
    static let cashOutMoneyLayerColor = UIColor(rgb: 0xBD2D2C)
    static let transMoneyLayerColor = UIColor(rgb: 0x306CD2)
    static let trueGreenLayerColor = UIColor(rgb: 0x67c23a)
    static let falseRedLayerColor = UIColor(rgb: 0xfa5555)
    static let lineBlueColor = UIColor(rgb: 0x0250B3)
    static let darkBlueLayer = UIColor(rgb: 0x012460)
    static let deepDarkBlue = UIColor(rgb:0x001E46)
    static let lightBlueLayer = UIColor(rgb: 0x1790FF)
    static let grayLayer = UIColor(rgb: 0xD9D9D9)
    static let leadingBlueLayer = UIColor(rgb: 0x204FAD)
    static let middleBlueLayer = UIColor(rgb: 0x2D6AC0)
    static let traillingBlueLayer = UIColor(rgb: 0x3A85D3)
    static let hintCellBackgroundBlue = UIColor(rgb:0xE2F6FF)
    static let placeHolderPrimyGary = UIColor(rgb:0xBDBDBD)
    static let placeHolderDarkGary = UIColor(rgb:0x8D8D8D)
    static let placeHolderlightGary = UIColor(rgb:0xEFEFEF)
    static let searchFieldBackground = UIColor(rgb: 0x011D4D)
    static let sectionBackground = UIColor(rgb: 0xF5F5F5)
    static let gradientStartBlue = UIColor(rgb: 0x002766)
    static let gradientEndBlue = UIColor(rgb: 0x001332)
    static let gradientCenterYellow = UIColor(rgb: 0xFADB14)
    static let labelBlue = UIColor(rgb: 0x438DF7)
    static let infoLineLabelBlue = UIColor(rgb: 0x5B9CF8)
    static let titleLabelBlack = UIColor(rgb: 0x262626)
    static let timeLabelBlack = UIColor(rgb: 0x8d8d8d)
    static let cellSelected = UIColor(rgb: 0xf5faff)
    static let btnBackgroundBlue = UIColor(rgb: 0x0050b3)
    
    static let imagePlaceHolder = UIImage(color: Themes.placeHolderPrimyGary, size: CGSize(width: 800, height: 800))
    
    
    
}





extension UIColor {
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
}
