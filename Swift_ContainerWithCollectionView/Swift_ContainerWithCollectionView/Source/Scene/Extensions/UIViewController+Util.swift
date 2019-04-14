//
//  UIViewController+Util.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/14.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

extension UIViewController {
    
    class func instantiateFromStoryboard() -> Self {
        return self._instantiateFromStoryboard()
    }
    
    private class func _instantiateFromStoryboard<T: UIViewController>() -> T {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as? T
        if controller == nil {
            assert(false, "生成したいViewControllerと同じ名前のStorybaordが見つからないか、Initial ViewControllerに設定されていない可能性があります。")
        }
        return controller!
    }
}
