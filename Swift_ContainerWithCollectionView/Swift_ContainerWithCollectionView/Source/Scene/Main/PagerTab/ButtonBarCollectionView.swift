//
//  ButtonBarCollectionView.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/05/01.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

enum SelectedBarAlignment {
    case center
    case progressive
}

enum SelectedBarVerticalAlignment {
    case middle
    case bottom
}

class ButtonBarCollectionView: UICollectionView {
    
    var selectedIndex = 0
    var selectedBarHeight: CGFloat = 5
    var selectedBarAlignment: SelectedBarAlignment = .center
    var selectedBarVerticalAlignment: SelectedBarVerticalAlignment = .bottom
    var selectedBarZPosition: CGFloat = 999 {
        didSet {
            self.selectedBar.layer.zPosition = self.selectedBarZPosition
        }
    }
    lazy var selectedBar: UIView = { [unowned self] in
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: self.selectedBarHeight))
        view.layer.zPosition = self.selectedBarZPosition
        view.backgroundColor = .darkGray
        return view
    }()
    var selectedBarRadius: CGFloat = 0 {
        didSet {
            self.selectedBar.layer.cornerRadius = self.selectedBarRadius
            self.selectedBar.layer.masksToBounds = true
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.addSubview(self.selectedBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubview(self.selectedBar)
    }
    
    override open func layoutSubviews() {
        self.updateSelectedBarYPosition()
    }
    
    private func updateSelectedBarYPosition() {
        var selectedBarFrame = self.selectedBar.frame
        
        switch self.selectedBarVerticalAlignment {
        case .middle:
            selectedBarFrame.origin.y = (self.frame.height - self.selectedBarHeight) / 2
        case .bottom:
            selectedBarFrame.origin.y = self.frame.height - self.selectedBarHeight
        }
        selectedBarFrame.size.height = self.selectedBarHeight
        self.selectedBar.frame = selectedBarFrame
    }
    
    func moveTo(index: Int, animated: Bool) {
        self.selectedIndex = index
        
        var selectedBarFrame = self.selectedBar.frame
        
        let selectedCellIndexPath = IndexPath(item: self.selectedIndex, section: 0)
        let attributes = layoutAttributesForItem(at: selectedCellIndexPath)
        let selectedCellFrame = attributes!.frame
        
        self.updateContentOffset(animated: animated, toCellFrame: selectedBarFrame, toIndex: self.selectedIndex)
        
        selectedBarFrame.size.width = selectedCellFrame.size.width
        selectedBarFrame.origin.x = selectedCellFrame.origin.x
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.selectedBar.frame = selectedBarFrame
            })
        } else {
            self.selectedBar.frame = selectedBarFrame
        }
    }
    
    func move(fromIndex: Int, toIndex: Int, progressPercentage: CGFloat) {
        self.selectedIndex = progressPercentage > 0.5 ? toIndex : fromIndex
        
        let numberOfItems = dataSource!.collectionView(self, numberOfItemsInSection: 0)
        
        var fromFrame: CGRect
        if fromIndex < 0 {
            let cellAtts = layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
            fromFrame = cellAtts!.frame.offsetBy(dx: -cellAtts!.frame.size.width, dy: 0)
        } else if fromIndex > numberOfItems - 1 {
            let cellAtts = layoutAttributesForItem(at: IndexPath(item: (numberOfItems - 1), section: 0))
            fromFrame = cellAtts!.frame.offsetBy(dx: cellAtts!.frame.size.width, dy: 0)
        } else {
            fromFrame = layoutAttributesForItem(at: IndexPath(item: fromIndex, section: 0))!.frame
        }
        
        var toFrame: CGRect
        if toIndex < 0 {
            let cellAtts = layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
            toFrame = cellAtts!.frame.offsetBy(dx: -cellAtts!.frame.size.width, dy: 0)
        } else if toIndex > numberOfItems - 1 {
            let cellAtts = layoutAttributesForItem(at: IndexPath(item: (numberOfItems - 1), section: 0))
            toFrame = cellAtts!.frame.offsetBy(dx: cellAtts!.frame.size.width, dy: 0)
        } else {
            toFrame = layoutAttributesForItem(at: IndexPath(item: toIndex, section: 0))!.frame
        }
        
        var targetFrame = fromFrame
        targetFrame.size.height = self.selectedBar.frame.height
        targetFrame.size.width += (toFrame.width - fromFrame.width) * progressPercentage
        targetFrame.origin.x += (toFrame.origin.x - fromFrame.origin.x) * progressPercentage
        
        self.selectedBar.frame = CGRect(x: targetFrame.origin.x,
                                        y: self.selectedBar.frame.origin.y,
                                        width: targetFrame.width,
                                        height: self.selectedBar.frame.height)
    
        var targetContentOffset: CGFloat = 0
        if self.contentSize.width > self.frame.size.width {
            let toContentOffset = self.contentOffsetForCell(cellFrame: toFrame, index: toIndex)
            let fromContentOffset = self.contentOffsetForCell(cellFrame: fromFrame, index: fromIndex)
            
            targetContentOffset = fromContentOffset + ((toContentOffset - fromContentOffset) * progressPercentage)
        }
        
        let animated = abs(self.contentOffset.x - targetContentOffset) > 30 || (fromIndex == toIndex)
        self.setContentOffset(CGPoint(x: targetContentOffset, y: 0), animated: animated)
    }
    
    private func updateContentOffset(animated: Bool, toCellFrame: CGRect, toIndex: Int) {
        let targetContentOffset = self.contentSize.width > self.frame.width ? self.contentOffsetForCell(cellFrame: toCellFrame, index: toIndex) : 0
        self.setContentOffset(CGPoint(x: targetContentOffset, y: 0), animated: animated)
    }
    
    private func contentOffsetForCell(cellFrame: CGRect, index: Int) -> CGFloat {
        let sectionInset = (self.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset
        var alignmentOffset: CGFloat = 0.0
        
        switch self.selectedBarAlignment {
        case .center:
            alignmentOffset = (self.frame.width - cellFrame.width) * 0.5
        case .progressive:
            let cellHalfWidth = cellFrame.width * 0.5
            let leftAlignmentOffset = sectionInset.left + cellHalfWidth
            let rigthAlignmentOffset = self.frame.width - sectionInset.right - cellHalfWidth
            let numberOfItems = dataSource!.collectionView(self, numberOfItemsInSection: 0)
            let progress = index / (numberOfItems - 1)
            alignmentOffset = leftAlignmentOffset + (rigthAlignmentOffset - leftAlignmentOffset) * CGFloat(progress) - cellHalfWidth
        }
        
        var contentOffset = cellFrame.origin.x - alignmentOffset
        contentOffset = max(0, contentOffset)
        contentOffset = min(self.contentSize.width - self.frame.size.width, contentOffset)
        return contentOffset
    }
}
