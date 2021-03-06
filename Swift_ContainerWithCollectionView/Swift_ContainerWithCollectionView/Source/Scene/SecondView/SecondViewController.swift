//
//  SecondViewController.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/21.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    var kind: PagerTabKind?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SecondViewController: MainPagerTabInfoProvider {
    var pagerTabKind: PagerTabKind {
        guard let _ = self.kind else { fatalError() }
        return .second
    }
}

