//
//  ViewController.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/14.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

//    @IBOutlet weak var ButtonBarViewCollectionView: UICollectionView!
    
//    var tabViewControllers: [UIViewController] {
//        return PagerTabDataSource.viewControllers
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.setupCollectionView()
    }
    
//    private func setupCollectionView() {
//        self.ButtonBarViewCollectionView.register(UINib(nibName: "ButtonBarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ButtonBarCollectionViewCell")
//
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: 150, height: 65)
//        layout.scrollDirection = .horizontal
//        self.ButtonBarViewCollectionView.collectionViewLayout = layout
//    }
}

//extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.tabViewControllers.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonBarCollectionViewCell", for: indexPath)
//        if let cell = cell as? ButtonBarCollectionViewCell {
//            cell.viewNameLabel.text = "Test"
//        }
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Tapped!!!!")
//    }
//}

