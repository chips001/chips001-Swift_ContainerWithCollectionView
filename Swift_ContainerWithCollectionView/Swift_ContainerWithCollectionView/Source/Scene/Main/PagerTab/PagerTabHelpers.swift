//
//  PagerTabHelpers.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/21.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import Foundation

enum SwipeDirection {
    case left
    case right
    case none
}

struct IndicatorInfo {
    let title: String
    
    init(title: String) {
        self.title = title
    }
}

protocol IndicatorInfoProvider {
    var indicatorInfo: IndicatorInfo { get }
}

enum PagerTabBehaviour {
    case common
    case progressive(elasticIndicatatorLimit: Bool)
    
    var isProgressiveIndicator: Bool {
        switch self {
        case .common:
            return false
        case .progressive:
            return true
        }
    }
    
    var isElasticIndicatorLimit: Bool {
        switch self {
        case .common:
            return false
        case .progressive(let elasticIndicatorLimit):
            return elasticIndicatorLimit
        }
    }
}
