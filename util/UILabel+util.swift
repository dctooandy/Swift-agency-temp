//
// Created by liq on 2018/4/9.
//

import Foundation
import UIKit

extension UILabel {
    
    static func customLabel(font:UIFont = UIFont.systemFont(ofSize: 12),
                            alignment:NSTextAlignment = .left,
                            textColor:UIColor = .white,
                            text:String = "loading...") -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.text = text
        return label
    }
}
