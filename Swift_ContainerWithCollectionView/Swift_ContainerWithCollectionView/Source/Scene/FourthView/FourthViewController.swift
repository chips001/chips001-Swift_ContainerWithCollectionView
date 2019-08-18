//
//  FourthViewController.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/21.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

class FourthViewController: UIViewController {
    
    var kind: PagerTabKind?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension FourthViewController: MainPagerTabInfoProvider {
    var pagerTabKind: PagerTabKind {
        guard let _ = self.kind else { fatalError() }
        return .fourth
    }
}

