//
//  PagerTabDataSource.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/17.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

struct MainPagerTabDataSource {
    
    static var viewControllers: [UIViewController] {
        
        var controllers: [UIViewController] = []
        
        let firstViewController = FirstViewController.instantiateFromStoryboard()
        controllers.append(firstViewController)
        
        let secondViewController = SecondViewController.instantiateFromStoryboard()
        controllers.append(secondViewController)
        
        let thirdViewController = ThirdViewController.instantiateFromStoryboard()
        controllers.append(thirdViewController)
        
        let fourthViewController = FourthViewController.instantiateFromStoryboard()
        controllers.append(fourthViewController)
        
        return controllers
    }
}
