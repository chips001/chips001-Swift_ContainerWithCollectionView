//
//  UIColor+Util.swift
//  Swift_ContainerWithCollectionView
//
//  Created by 一木 英希 on 2019/05/16.
//  Copyright © 2019 一木 英希. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func colorLerp(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
        let t = max(0, min(1, progress))
        
        var redA: CGFloat = 0
        var greenA: CGFloat = 0
        var blueA: CGFloat = 0
        var alphaA: CGFloat = 0
        from.getRed(&redA, green: &greenA, blue: &blueA, alpha: &alphaA)
        
        var redB: CGFloat = 0
        var greenB: CGFloat = 0
        var blueB: CGFloat = 0
        var alphaB: CGFloat = 0
        to.getRed(&redB, green: &greenB, blue: &blueB, alpha: &alphaB)
        
        let lerp = { (a: CGFloat, b: CGFloat, t: CGFloat) -> CGFloat in
            return a + (b - a) * t
        }
        
        let r = lerp(redA, redB, t)
        let g = lerp(greenA, greenB, t)
        let b = lerp(blueA, blueB, t)
        let a = lerp(alphaA, alphaB, t)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
