//
//  ButtonBarPagerTabViewController.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/21.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

class ButtonBarPagerTabViewController: PagerTabViewController, PagerTabDataSource {
    
    @IBOutlet weak var buttonBarCollectionView: ButtonBarCollectionView!
    var settings = ButtonBerPagerTabSettings()
    private var shouldUpdateButtonBarView = true
    private lazy var cachedCellWidths: [CGFloat]? = { [unowned self] in
        return self.calculateWidths()
    }()
    var changeCurrentIndex: ((_ oldCell: ButtonBarCollectionViewCell?, _ newCell: ButtonBarCollectionViewCell?, _ animated: Bool) -> Void)?
    var changeCurrentIndexProgressive: ((_ oldCell: ButtonBarCollectionViewCell?, _ newCell: ButtonBarCollectionViewCell?, _ progressPercentage: CGFloat, _ changeCurrentIndex: Bool, _ animated: Bool) -> Void)?

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
        
        let tmpButtonBarCollectionView = self.buttonBarCollectionView ?? {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal
            let buttonBarHeight = self.settings.style.buttonBarHeight ?? 44
            
            let buttonBar = ButtonBarCollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: buttonBarHeight), collectionViewLayout: flowLayout)
            buttonBar.backgroundColor = .orange
            buttonBar.selectedBar.backgroundColor = .darkGray
            buttonBar.autoresizingMask = .flexibleWidth
            
            var newContainerViewFrame = self.containerView.frame
            newContainerViewFrame.origin.y = buttonBarHeight
            newContainerViewFrame.size.height = self.containerView.frame.height - (buttonBarHeight - self.containerView.frame.origin.y)
            self.containerView.frame = newContainerViewFrame
            
            return buttonBar
        }()
        self.buttonBarCollectionView = tmpButtonBarCollectionView
        
        if self.buttonBarCollectionView.superview == nil {
            self.view.addSubview(self.buttonBarCollectionView)
        }
        if self.buttonBarCollectionView.delegate == nil {
            self.buttonBarCollectionView.delegate = self
        }
        if self.buttonBarCollectionView.dataSource == nil {
            self.buttonBarCollectionView.dataSource = self
        }
        self.buttonBarCollectionView.scrollsToTop = false
        
        let flowLayout = self.buttonBarCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = self.settings.style.buttonBarMinimumInteritemSpecing ?? flowLayout.minimumInteritemSpacing
        flowLayout.minimumLineSpacing = self.settings.style.buttonBarMinimunLineSpecing ?? flowLayout.minimumLineSpacing
        let sectionInset = flowLayout.sectionInset
        flowLayout.sectionInset = UIEdgeInsets(top: sectionInset.top,
                                               left: self.settings.style.buttonBarLeftContentInset ?? sectionInset.left,
                                               bottom: sectionInset.bottom,
                                               right: self.settings.style.buttonBarRightContentInset ?? sectionInset.right)
        
        self.buttonBarCollectionView.showsHorizontalScrollIndicator = false
        self.buttonBarCollectionView.backgroundColor = self.settings.style.buttonBarBackgroundColer ?? self.buttonBarCollectionView.backgroundColor
        self.buttonBarCollectionView.selectedBarHeight = self.settings.style.selectedBarHeight
        self.buttonBarCollectionView.selectedBarRadius = self.settings.style.selectedBarRedius
        self.buttonBarCollectionView.selectedBarZPosition = self.settings.style.selectedBarZPosition
        self.buttonBarCollectionView.selectedBar.backgroundColor = self.settings.style.selectedBarBackgroundColor
        self.buttonBarCollectionView.selectedBarVerticalAlignment = self.settings.style.selectedBarVerticalAlignment
        self.buttonBarCollectionView.selectedBarAlignment = self.settings.style.selectedBarAlignment
        
        self.buttonBarCollectionView.register(UINib(nibName: "ButtonBarCollectionViewCell", bundle: Bundle(for: ButtonBarCollectionViewCell.self)), forCellWithReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.buttonBarCollectionView.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard self.isViewAppearing || self.isViewRotating else { return }
        self.cachedCellWidths = self.calculateWidths()
        self.buttonBarCollectionView.collectionViewLayout.invalidateLayout()
        self.buttonBarCollectionView.moveTo(index: self.currentIndex, animated: false)
    }
    
    override func reloadPagerTabView() {
        super.reloadPagerTabView()
        guard self.isViewLoaded else { return }
        self.buttonBarCollectionView.reloadData()
        self.cachedCellWidths = self.calculateWidths()
        self.buttonBarCollectionView.moveTo(index: self.currentIndex, animated: false)
    }
    
    override func moveToViewController(at index: Int, animated: Bool = true) {
        if self.currentIndex != index {
            let oldCell = self.buttonBarCollectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as? ButtonBarCollectionViewCell
            oldCell?.viewNameLabel.textColor = self.settings.style.buttonBarItemTitleColor
        }
        super.moveToViewController(at: index, animated: animated)
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        
        guard scrollView == self.containerView else { return }
        self.shouldUpdateButtonBarView = true
    }
    
    private func calculateWidths() -> [CGFloat] {
        var minimumCellWidths = [CGFloat]()
        var collectionViewContentWidth: CGFloat = 0
        
        let calcWidth = { [weak self] (info: IndicatorInfo) -> CGFloat in
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = self?.settings.style.buttonBarItemFont
            label.text = info.title
            let labelSize = label.intrinsicContentSize
            return labelSize.width + (self?.settings.style.buttonBarItemLeftRightMargin ?? 8) * 2
        }
        
        for viewController in self.viewControllers {
            let provider = viewController as! IndicatorInfoProvider
            let indicatorInfo = provider.indicatorInfo
            let width = calcWidth(indicatorInfo)
            collectionViewContentWidth += width
            minimumCellWidths.append(width)
        }
        
        let flowLayout = self.buttonBarCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let numberOfCells = self.viewControllers.count
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumInteritemSpacing
        collectionViewContentWidth += cellSpacingTotal
        
        let collectionViewAvailableVisibleWidth = self.buttonBarCollectionView.frame.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        
        if !self.settings.style.buttonBarItemsShouldFillAvailableWidth || collectionViewAvailableVisibleWidth < collectionViewContentWidth {
            return minimumCellWidths
        } else {
            let stretchdCellWithIfAllEqual = (collectionViewAvailableVisibleWidth - cellSpacingTotal) / CGFloat(numberOfCells)
            let generalMinimumCellWidth = self.calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: stretchdCellWithIfAllEqual, previousNumberOfLargeCells: 0)
            var stretchedCellWidths = [CGFloat]()
            
            for minimumCellWidthValue in minimumCellWidths {
                let cellWidth = (minimumCellWidthValue > generalMinimumCellWidth) ? minimumCellWidthValue : generalMinimumCellWidth
                stretchedCellWidths.append(cellWidth)
            }
            return stretchedCellWidths
        }
    }
    
    func calculateStretchedCellWidths(_ minimumCellWidths: [CGFloat], suggestedStretchedCellWidth: CGFloat, previousNumberOfLargeCells: Int) -> CGFloat {
        var numberOfLargeCells = 0
        var totalWidthOfLargeCells: CGFloat = 0
        
        for minimumCellWidthValue in minimumCellWidths where minimumCellWidthValue > suggestedStretchedCellWidth {
            totalWidthOfLargeCells += minimumCellWidthValue
            numberOfLargeCells += 1
        }
        
        guard numberOfLargeCells > previousNumberOfLargeCells else { return suggestedStretchedCellWidth }
        
        let flowLayout = self.buttonBarCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let collectionViewAvailiableWidth = self.buttonBarCollectionView.frame.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        let numberOfCells = minimumCellWidths.count
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumInteritemSpacing
        
        let numbersOfSmallCells = numberOfCells - numberOfLargeCells
        let newSuggestedStretchedCellWidth = (collectionViewAvailiableWidth - totalWidthOfLargeCells - cellSpacingTotal) / CGFloat(numbersOfSmallCells)
        
        return self.calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: newSuggestedStretchedCellWidth, previousNumberOfLargeCells: numberOfLargeCells)
    }
}

extension ButtonBarPagerTabViewController: PagerTabDelegate, PagerTabProgressiveDelegate {
    
    // MARK: - PagerTabDelegate
    func updateIndicator(fromIndex: Int, toIndex: Int) {
        guard self.shouldUpdateButtonBarView else { return }
        self.buttonBarCollectionView.moveTo(index: toIndex, animated: false)
        
        if let changeCurrentIndex = self.changeCurrentIndex {
            let oldCell = self.buttonBarCollectionView.cellForItem(at: IndexPath(item: self.currentIndex != fromIndex ? fromIndex : toIndex, section: 0)) as? ButtonBarCollectionViewCell
            let newCell = self.buttonBarCollectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as? ButtonBarCollectionViewCell
            changeCurrentIndex(oldCell, newCell, true)
        }
    }

    // MARK: - PagerTabProgressiveDelegate
    func updateIndicator(fromIndex: Int, toIndex: Int, progressPercentage: CGFloat, indexWasChanged: Bool) {
        guard self.shouldUpdateButtonBarView else { return }
        self.buttonBarCollectionView.move(fromIndex: fromIndex, toIndex: toIndex, progressPercentage: progressPercentage)
        
        if let changeCurrentIndexProgressive = self.changeCurrentIndexProgressive {
            let oldCell = self.buttonBarCollectionView.cellForItem(at: IndexPath(item: self.currentIndex != fromIndex ? fromIndex : toIndex, section: 0)) as? ButtonBarCollectionViewCell
            let newCell = self.buttonBarCollectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as? ButtonBarCollectionViewCell
            changeCurrentIndexProgressive(oldCell, newCell, progressPercentage, indexWasChanged, true)
        }
    }
}

extension ButtonBarPagerTabViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellWithValue = self.cachedCellWidths?[indexPath.row] else {
            fatalError("\(indexPath.row)のcachedCellWidthsをnilにしないでください。")
        }
        return CGSize(width: cellWithValue, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != self.currentIndex else { return }
        
        self.buttonBarCollectionView.moveTo(index: indexPath.item, animated: true)
        self.shouldUpdateButtonBarView = false
        
        let oldCell = self.buttonBarCollectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as? ButtonBarCollectionViewCell
        let newCwll = self.buttonBarCollectionView.cellForItem(at: IndexPath(item: indexPath.item, section: 0)) as? ButtonBarCollectionViewCell
        
        if self.pagerBehaviour.isProgressiveIndicator {
            if let changeCurrentIndexProgressive = self.changeCurrentIndexProgressive {
                changeCurrentIndexProgressive(oldCell, newCwll, 1, true, true)
            }
        } else {
            if let changeCurrentIndex = self.changeCurrentIndex {
                changeCurrentIndex(oldCell, newCwll, true)
            }
        }
        self.moveToViewController(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewControllers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ButtonBarCollectionViewCell else {
            fatalError("UICollectionViewCellはButtonBarCollectionViewCellであるか、それから拡張する必要があります")
        }
        
        let provider = self.viewControllers[indexPath.item] as! IndicatorInfoProvider
        let indicatorInfo = provider.indicatorInfo
        
        cell.viewNameLabel.text = indicatorInfo.title
        cell.viewNameLabel.font = self.settings.style.buttonBarItemFont
        
        if indexPath.item == self.currentIndex {
            cell.viewNameLabel.textColor = self.settings.style.buttonBarItemTitleSelectedColor
        } else {
            cell.viewNameLabel.textColor = self.settings.style.buttonBarItemTitleColor ?? cell.viewNameLabel.textColor
        }
        cell.contentView.backgroundColor = self.settings.style.buttonBarBackgroundColer ?? cell.contentView.backgroundColor
        cell.backgroundColor = self.settings.style.buttonBarItemBackgroundColor ?? cell.backgroundColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? ButtonBarCollectionViewCell {
            if indexPath.item == self.currentIndex {
                cell.viewNameLabel.textColor = self.settings.style.buttonBarItemTitleSelectedColor
            } else {
                cell.viewNameLabel.textColor = self.settings.style.buttonBarItemTitleColor
            }
        }
    }
}

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
