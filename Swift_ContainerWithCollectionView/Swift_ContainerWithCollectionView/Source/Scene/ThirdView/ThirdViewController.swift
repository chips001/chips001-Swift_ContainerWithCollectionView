//
//  ThirdViewController.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/21.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {
    
    var kind: PagerTabKind?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ThirdViewController: MainPagerTabInfoProvider {
    var pagerTabKind: PagerTabKind {
        guard let kind = self.kind else { fatalError() }
        return .third
    }
}

