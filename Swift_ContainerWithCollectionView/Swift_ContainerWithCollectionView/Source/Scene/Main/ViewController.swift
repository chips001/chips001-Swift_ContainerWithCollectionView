//
//  ViewController.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/04/14.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ButtonBarViewCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ButtonBarViewCollectionView.register(UINib(nibName: "ButtonBarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ButtonBarCollectionViewCell")
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonBarCollectionViewCell", for: indexPath) as! ButtonBarCollectionViewCell
        cell.viewNameLabel.text = "Test"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Tapped!!!!")
    }
}

