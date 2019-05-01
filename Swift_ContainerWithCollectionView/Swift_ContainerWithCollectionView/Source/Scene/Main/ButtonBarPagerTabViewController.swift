//
//  ButtonBarPagerTabViewController.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/21.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

struct ButtonBerPagerTabSettings {
    
    var style = Style()
    
    struct Style {
        var buttonBarBackgroundColer: UIColor?
        var buttonBarMinimumInteritemSpecing: CGFloat?
        var buttonBarMinimunLineSpecing: CGFloat?
        var buttonBarLeftContentInset: CGFloat?
        var buttonBarRightContentInset: CGFloat?
        
        var selectedBarHeight: CGFloat = 5
        var selectedBarBackgroundColor = UIColor.darkGray
        var selectedBarVerticalAlignment: SelectedBarVerticalAlignment = .bottom
        var selectedBarAlignment: SelectedBarAlignment = .center
        var selectedBarRedius: CGFloat = 0
        var selectedBarZPosition: CGFloat = 999
        
        var buttonBarItemBackgroundColor: UIColor?
        var buttonBarItemFont = UIFont.systemFont(ofSize: 17)
        var buttonBarItemLeftRightMargin: CGFloat = 8
        var buttonBarItemTitleColor: UIColor?
        var buttonBarItemTitleSelectedColor: UIColor?
        var buttonBarItemsShouldFillAvailableWidth = true
        var buttonBarHeight: CGFloat?
    }
}

class ButtonBarPagerTabViewController: PagerTabViewController, PagerTabDataSource {
    
    @IBOutlet weak var buttonBarCollectionView: ButtonBarCollectionView!
    var settings = ButtonBerPagerTabSettings()
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.delegate = self
        self.datasource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.datasource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension ButtonBarPagerTabViewController: PagerTabDelegate, PagerTabProgressiveDelegate {
    
    func updateIndicator(fromIndex: Int, toIndex: Int, progressPercentage: CGFloat, indexWasChanged: Bool) {
        <#code#>
    }
    
    func updateIndicator(fromIndex: Int, toIndex: Int) {
        <#code#>
    }
}

extension ButtonBarPagerTabViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
}
