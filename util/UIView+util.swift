//
//  UIView+util.swift
//  agency.ios
//
//  Created by Andy Chen on 2019/4/15.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func addShadowBgView(radius:CGFloat) -> UIView {
        let shadow = UIView()
        let frame = self.frame
        shadow.layer.shadowOpacity = 0.3
        shadow.layer.cornerRadius = 10
        shadow.addSubview(self)
        shadow.frame = frame
        self.snp.makeConstraints { maker in
            maker.edges.equalTo(UIEdgeInsets.zero)
        }
        return shadow
    }
    
    func addGradientBlueLayer(size:CGSize = .zero) {
        let layerSize = size == .zero ? frame.size :size
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x:0,
                                     y:0,
                                     width:layerSize.width,
                                     height:layerSize.height)
        gradientLayer.colors = [Themes.gradientStartBlue.cgColor,Themes.gradientEndBlue.cgColor]
        gradientLayer.startPoint = CGPoint(x:0.5, y:0.0)
        gradientLayer.endPoint = CGPoint(x:0.5, y:1.0)
        layer.insertSublayer(gradientLayer, at:0)
    }
    
    func applyCornerRadius(radius:CGFloat = 5) {
        layer.masksToBounds = true
        layer.cornerRadius = radius
    }
    
    func applyShadow(size:CGSize = CGSize(width: 0, height: 5), radius:CGFloat = 5) {
        layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = size
        layer.shadowRadius = radius
        layer.shadowOpacity = 1
    }
    
    func applyCornerAndShadow(radius:CGFloat = 5){
        layer.addShadow()
        layer.roundCorners(radius: radius)
    }
    
    func addBottomSeparator(color:UIColor, edgeSpacing:CGFloat = 0) {
        let separator = UIView(color:color)
        self.addSubview(separator)
        separator.snp.makeConstraints { maker in
            maker.bottom.equalToSuperview()
            maker.leading.equalToSuperview().offset(edgeSpacing)
            maker.trailing.equalToSuperview().offset(-edgeSpacing)
            maker.height.equalTo(1)
        }
    }
    convenience init(color:UIColor) {
        self.init(frame:.zero)
        self.backgroundColor = color
    }
    
    func applyDefaultLayer() {
        layer.masksToBounds = false
        layer.cornerRadius = 0
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 0
    }
    
    func round(corners:UIRectCorner, radius:CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale);
        
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: self.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() };
        UIGraphicsEndImageContext();
        return image;
    }
    
}
