//
//  MainPagerTabViewController.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/21.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

class MainPagerTabViewController: ButtonBarPagerTabViewController {
    
    var pagerTabKind: PagerTabKind?

    override func viewDidLoad() {
        
        self.settings.style.buttonBarBackgroundColer = .clear
        self.settings.style.buttonBarItemFont = UIFont.mainBoldFont(ofSize: 14)
        self.settings.style.buttonBarItemBackgroundColor = .clear
//        self.settings.style.buttonBarItemTitleColor = UIColor(hex: 0x424242)
        self.settings.style.buttonBarItemTitleSelectedColor = .white
        self.settings.style.buttonBarItemLeftRightMargin = 12
        self.settings.style.buttonBarMinimumInteritemSpecing = 0
        self.settings.style.buttonBarMinimunLineSpecing = 0
        self.settings.style.buttonBarLeftContentInset = 5
        self.settings.style.buttonBarRightContentInset = 5
        
        self.settings.style.selectedBarHeight = 30
        self.settings.style.selectedBarRedius = 15
        self.settings.style.selectedBarZPosition = -1
        self.settings.style.selectedBarVerticalAlignment = .middle
//        self.settings.style.selectedBarBackgroundColor = UIColor(hex: 0x5fbef1)
        
        self.changeCurrentIndex = { [weak self] (_ oldCell: ButtonBarCollectionViewCell?, _ newCell: ButtonBarCollectionViewCell?, _ animated: Bool) -> Void in
            oldCell?.viewNameLabel.textColor = self?.settings.style.buttonBarItemTitleColor
            newCell?.viewNameLabel.textColor = self?.settings.style.buttonBarItemTitleSelectedColor
        }
        
        self.changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarCollectionViewCell?, newCell: ButtonBarCollectionViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard
                let `self` = self,
                let normalColor = self.settings.style.buttonBarItemTitleColor,
                let selectedColor = self.settings.style.buttonBarItemTitleSelectedColor
            else {
                return
            }
            
            if changeCurrentIndex && progressPercentage == 1 {
                if let oldCell = oldCell {
                    UIView.transition(with: oldCell.viewNameLabel, duration: 0.3, options: [.transitionCrossDissolve], animations: { oldCell.viewNameLabel.textColor = normalColor }, completion: nil)
                }
                if let newCell = newCell {
                    UIView.transition(with: newCell.viewNameLabel, duration: 0.3, options: [.transitionCrossDissolve], animations: { newCell.viewNameLabel.textColor = selectedColor }, completion: nil)
                }
                return
            }
            
            let fromColor = UIColor.colorLerp(from: selectedColor, to: normalColor, progress: 1 - progressPercentage)
            let toColor = UIColor.colorLerp(from: selectedColor, to: normalColor, progress: progressPercentage)
            
            if 0 <= progressPercentage && progressPercentage < 0.5 {
                oldCell?.viewNameLabel.textColor = fromColor
                newCell?.viewNameLabel.textColor = toColor
            } else if 0.5 < progressPercentage && progressPercentage <= 1 {
                oldCell?.viewNameLabel.textColor = toColor
                newCell?.viewNameLabel.textColor = fromColor
            }
        }
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let pagerTabKind = self.pagerTabKind {
            self.moveToViewController(pagerTabKind: pagerTabKind)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.pagerTabKind = nil
        super.viewDidDisappear(animated)
    }
    
    public func moveToViewController(pagerTabKind: PagerTabKind) {
        for (i, controller) in self.viewControllers.enumerated() {
            if let provider = controller as? MainPagerTabInfoProvider, provider.pagerTabKind == pagerTabKind {
                self.moveToViewController(at: i)
            }
        }
    }
    
    @IBOutlet weak var userAttributeInvitationCellView: UIView!
    
    override var tabViewControllers: [UIViewController] {
        return MainPagerTabDataSource.viewControllers
    }
}

protocol MainPagerTabInfoProvider: IndicatorInfoProvider {
    var pagerTabKind: PagerTabKind { get }
}

extension MainPagerTabInfoProvider {
    var indicatorInfo: IndicatorInfo {
        return IndicatorInfo(title: self.pagerTabKind.description)
    }
}
