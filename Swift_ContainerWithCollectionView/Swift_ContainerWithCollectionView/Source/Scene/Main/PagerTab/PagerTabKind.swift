//
//  PagerTabKind.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/19.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import Foundation

enum PagerTabKind: CustomStringConvertible {
    case first
    case second
    case third
    case fourth
    
    var description: String {
        switch self {
        case .first:  return "FirstView"
        case .second: return "SecondView"
        case .third:  return "ThirdView"
        case .fourth: return "FourthView"
        }
    }
}
