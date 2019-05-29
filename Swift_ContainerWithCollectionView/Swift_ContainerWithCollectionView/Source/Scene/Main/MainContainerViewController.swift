//
//  ViewController.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/14.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

class MainContainerViewController: UIViewController {
    
    var pagerTabKind: PagerTabKind?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pagerTabSegue" {
            let controller = segue.destination as! MainPagerTabViewController
            controller.pagerTabKind = self.pagerTabKind
        }
    }
}
