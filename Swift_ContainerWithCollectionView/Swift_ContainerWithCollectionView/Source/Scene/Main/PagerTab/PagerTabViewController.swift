//
//  PagerTabViewController.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/21.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

protocol PagerTabDataSource: class {
    var tabViewControllers: [UIViewController] { get }
}

protocol PagerTabDelegate: class {
    func updateIndicator(fromIndex: Int, toIndex: Int)
}

protocol PagerTabProgressiveDelegate: PagerTabDelegate {
    func updateIndicator(fromIndex: Int, toIndex: Int, progressPercentage: CGFloat, indexWasChanged: Bool)
}

class PagerTabViewController: UIViewController {
    
    weak var datasource: PagerTabDataSource?
    weak var delegate: PagerTabDelegate?
    var pagerBehaviour = PagerTabBehaviour.progressive(elasticIndicatatorLimit: true)
    
    @IBOutlet weak var containerView: UIScrollView!
    
    var currentIndex = 0
    var viewControllers: [UIViewController] = []
    var viewControllersForScrolling: [UIViewController]?
    var isViewRotating = false
    var isViewAppearing = false
    var lastPageSize: CGSize = .zero
    var pageWidth: CGFloat { return self.containerView.bounds.width }
    var lastContentOffsetX: CGFloat = 0.0
    var swipeDirection: SwipeDirection {
        if self.containerView.contentOffset.x > self.lastContentOffsetX {
            return .left
        } else if self.containerView.contentOffset.x < self.lastContentOffsetX {
            return .right
        }
        return .none
    }
    var scrollPercentage: CGFloat {
        if self.swipeDirection != .right {
            // fmod : 余剰計算
            let module = fmod(self.containerView.contentOffset.x >= 0 ? self.containerView.contentOffset.x : self.pageWidth + self.containerView.contentOffset.x, self.pageWidth)
            return (module == 0.0) ? 1.0 : (module / self.pageWidth)
        }
        return 1 - fmod((self.containerView.contentOffset.x >= 0)
            ? self.containerView.contentOffset.x
            : self.pageWidth + self.containerView.contentOffset.x
            , self.pageWidth) / self.pageWidth
    }
    var tabViewControllers: [UIViewController] {
        assertionFailure("サブクラスはPagerTabDataSourceのtabViewControllersメソッドを実装する必要があります")
        return []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupContainerView()
    }
    
//    Deprecated
//    Manually forward calls to the viewWillTransition(to:with:) method as needed.
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isViewAppearing = true
        self.children.forEach { $0.beginAppearanceTransition(true, animated: animated) }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateIfNeed()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isViewAppearing = false
        self.children.forEach { $0.endAppearanceTransition() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.children.forEach { $0.beginAppearanceTransition(false, animated: animated) }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.children.forEach { $0.endAppearanceTransition() }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.isViewRotating = true
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let me = self else { return }
            me.isViewRotating = false
            me.updateIfNeed()
        }
    }
    
    func setupContainerView() {
        let tmpContainerView = self.containerView ?? {
            let containerView = UIScrollView(frame: CGRect(x:0, y:0, width: self.view.bounds.width, height: self.view.bounds.height))
            containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return containerView
            }()
        
        self.containerView = tmpContainerView
        if self.containerView.superview == nil {
            self.view.addSubview(self.containerView)
        }
        
        self.containerView.bounces = true
        self.containerView.alwaysBounceHorizontal = true
        self.containerView.alwaysBounceVertical = false
        self.containerView.scrollsToTop = false
        self.containerView.delegate = self
        self.containerView.showsVerticalScrollIndicator = false
        self.containerView.showsHorizontalScrollIndicator = false
        self.containerView.isPagingEnabled = true
        
        self.reloadViewControllers()
        
        let childController = self.viewControllers[self.currentIndex]
        self.addChild(childController)
        childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.containerView.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
    func pageOffsetForChild(at index: Int) -> CGFloat {
        return CGFloat(index) * self.containerView.bounds.width
    }
    
    func virtualPage(contentOffset: CGFloat) -> Int {
        return Int((contentOffset + 1.5 * self.pageWidth) / pageWidth) - 1
    }
    
    func pageFor(virtualPage: Int) -> Int {
        if virtualPage < 0 {
            return 0
        }
        if virtualPage > self.viewControllers.count - 1 {
            return self.viewControllers.count - 1
        }
        return virtualPage
    }
    
    func updateContentAndCurrentIndex() {
        if self.lastPageSize.width != self.pageWidth {
            self.containerView.contentOffset = CGPoint(x: self.pageOffsetForChild(at: self.currentIndex), y: 0)
        }
        self.lastPageSize = self.containerView.bounds.size
        
        let pagerViewControllers = self.viewControllersForScrolling ?? self.viewControllers
        self.containerView.contentSize = CGSize(width: self.pageWidth * CGFloat(pagerViewControllers.count), height: 0)
        
        for (index, childController) in pagerViewControllers.enumerated() {
            let pageOffset = self.pageOffsetForChild(at: index)
            
            if abs(self.containerView.contentOffset.x - pageOffset) < self.pageWidth {
                if childController.parent != nil {
                    childController.view.frame = CGRect(x: pageOffset, y: 0, width: self.containerView.bounds.width, height: self.containerView.bounds.height)
                } else {
                    childController.beginAppearanceTransition(true, animated: false)
                    self.addChild(childController)
                    childController.view.frame = CGRect(x: pageOffset, y: 0, width: self.containerView.bounds.width, height: self.containerView.bounds.height)
                    childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    self.containerView.addSubview(childController.view)
                    childController.didMove(toParent: self)
                    childController.endAppearanceTransition()
                }
            } else {
                if childController.parent != nil {
                    childController.beginAppearanceTransition(false, animated: false)
                    childController.willMove(toParent: nil)
                    childController.view.removeFromSuperview()
                    childController.removeFromParent()
                    childController.endAppearanceTransition()
                }
            }
        }
        
        let oldCurrentIndex = self.currentIndex
        let virtualPage = self.virtualPage(contentOffset: self.containerView.contentOffset.x)
        let newCurrentIndex = pageFor(virtualPage: virtualPage)
        self.currentIndex = newCurrentIndex
        let changeCurrentIndex = newCurrentIndex != oldCurrentIndex
        
        if let progressiveDelegate = delegate as? PagerTabProgressiveDelegate, self.pagerBehaviour.isProgressiveIndicator {
            let (fromIndex, toIndex, scrollPercentage) = self.progressiveIndicatorData(virtualPage)
            progressiveDelegate.updateIndicator(fromIndex: fromIndex, toIndex: toIndex, progressPercentage: scrollPercentage, indexWasChanged: changeCurrentIndex)
        } else {
            delegate?.updateIndicator(fromIndex: min(oldCurrentIndex, pagerViewControllers.count - 1), toIndex: newCurrentIndex)
        }
    }
    
    private func progressiveIndicatorData(_ virtualPage: Int) -> (Int, Int, CGFloat) {
        let count = self.viewControllers.count
        var fromIndex = self.currentIndex
        var toIndex = self.currentIndex
        let direction = self.swipeDirection
        
        if direction == .left {
            if virtualPage < 0 {
                fromIndex = -1
                toIndex = 0
            } else if virtualPage > count - 1 {
                fromIndex = count - 1
                toIndex = count
            } else {
                if self.scrollPercentage >= 0.5 {
                    fromIndex = max(toIndex - 1, -1)
                } else {
                    toIndex = fromIndex + 1
                }
            }
        } else if direction == .right {
            if virtualPage < 0 {
                fromIndex = 0
                toIndex = -1
            } else if virtualPage > count - 1 {
                fromIndex = count
                toIndex = count - 1
            } else {
                if self.scrollPercentage > 0.5 {
                    fromIndex = min(toIndex + 1, count)
                } else {
                    toIndex = fromIndex - 1
                }
            }
        }
        
        if self.pagerBehaviour.isElasticIndicatorLimit {
            return (fromIndex, toIndex, self.scrollPercentage)
        } else {
            let percentage = (toIndex < 0 || toIndex > count - 1 || fromIndex < 0 || fromIndex > count - 1) ? 0.0 : self.scrollPercentage
            if toIndex < 0 {
                toIndex = 0
            }
            if toIndex > count - 1 {
                toIndex = count - 1
            }
            if fromIndex < 0 {
                fromIndex = 0
            }
            if fromIndex > count - 1 {
                fromIndex = count - 1
            }
            return (fromIndex, toIndex, percentage)
        }
    }
    
    func moveTo(viewController: UIViewController, animated: Bool = true) {
        self.moveToViewController(at: self.viewControllers.firstIndex(of: viewController)!, animated: animated)
    }
    
    func moveToViewController(at index: Int, animated: Bool = true) {
        guard isViewLoaded && self.currentIndex != index else { return }
        
        if animated && abs(self.currentIndex - index) > 1 {
            var tmpViewControllers = self.viewControllers
            let currentChildViewController = self.viewControllers[self.currentIndex]
            let fromIndex = self.currentIndex < index ? index - 1 : index + 1
            let fromChildViewController = self.viewControllers[fromIndex]
            tmpViewControllers[fromIndex] = currentChildViewController
            tmpViewControllers[self.currentIndex] = fromChildViewController
            self.viewControllersForScrolling = tmpViewControllers
            self.containerView.setContentOffset(CGPoint(x: self.pageOffsetForChild(at: fromIndex), y: 0), animated: false)
            (navigationController?.view ?? view).isUserInteractionEnabled = false
        } else {
            (navigationController?.view ?? view)?.isUserInteractionEnabled = !animated
            self.containerView.setContentOffset(CGPoint(x: self.pageOffsetForChild(at: index), y: 0), animated: animated)
        }
    }
    
    func reloadPagerTabView() {
        guard isViewLoaded else { return }
        for childController in self.viewControllers where childController.parent != nil {
            childController.beginAppearanceTransition(false, animated: false)
            childController.willMove(toParent: nil)
            childController.view.removeFromSuperview()
            childController.removeFromParent()
            childController.endAppearanceTransition()
        }
        self.reloadViewControllers()
        if self.currentIndex > self.viewControllers.count - 1 {
            self.currentIndex = self.viewControllers.count - 1
        }
        self.containerView.contentOffset = CGPoint(x: pageOffsetForChild(at: self.currentIndex), y: 0)
        self.updateContentAndCurrentIndex()
    }
    
    private func reloadViewControllers() {
        guard let dataSource = self.datasource else {
            fatalError("dataSourceはnilであってはいけません。")
        }
        self.viewControllers = dataSource.tabViewControllers
        
        guard !self.viewControllers.isEmpty else {
            fatalError("DataSourceのviewControllersは少なくとも1つの子View Controllerを提供する必要があります。")
        }
        
        self.viewControllers.forEach {
            if !($0 is IndicatorInfoProvider) {
                fatalError("DataSourceのviewControllersメソッドによって提供されるすべてのView Controllerは、InfoProviderに準拠している必要があります。")
            }
        }
    }
    
    private func updateIfNeed() {
        if self.isViewLoaded && !self.lastPageSize.equalTo(self.containerView.bounds.size) {
            self.updateContentAndCurrentIndex()
        }
    }
}

extension PagerTabViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.containerView == scrollView {
            self.updateContentAndCurrentIndex()
            self.lastContentOffsetX = scrollView.contentOffset.x
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if self.containerView == scrollView {
            self.viewControllersForScrolling = nil
            (navigationController?.view ?? view)?.isUserInteractionEnabled = true
            self.updateContentAndCurrentIndex()
        }
    }
}
