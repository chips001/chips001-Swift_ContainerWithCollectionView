//
//  UIFont+Util.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/05/07.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func mainFont(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "HiraginoSans-W3", size: ofSize) ??
            UIFont(name: "HiraKakuProN-W3", size: ofSize) ??
            UIFont.systemFont(ofSize: ofSize)
    }
    
    static func mainBoldFont(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "HiraginoSans-W6", size: ofSize) ??
            UIFont(name: "HiraKakuProN-W6", size: ofSize) ??
            UIFont.systemFont(ofSize: ofSize)
    }
}
