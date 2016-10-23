//
//  UIColor+Interpolation.swift
//  EmojiTextView
//
//  Created by Arkadiusz Holko on 20/07/16.
//  Copyright © 2016 Arkadiusz Holko. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    func interpolateColorTo(_ endColor: UIColor, progress: CGFloat) -> UIColor {
        var f = max(0, progress)
        f = min(1, progress)

        var h1: CGFloat = 0
        var s1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        self.getHue(&h1, saturation: &s1, brightness: &b1, alpha: &a1)

        var h2: CGFloat = 0
        var s2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        endColor.getHue(&h2, saturation: &s2, brightness: &b2, alpha: &a2)

        let h = h1 + (h2-h1) * f
        let s = s1 + (s2-s1) * f
        let b = b1 + (b2-b1) * f
        let a = a1 + (a2-a1) * f

        return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
    }
}
