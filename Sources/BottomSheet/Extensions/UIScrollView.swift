//
//  File.swift
//  
//
//  Created by Adam Salih on 26.02.2021.
//

import UIKit

extension UIScrollView {
    var normalizedContentOffset: CGPoint {
        CGPoint(
            x: contentOffset.x + safeAreaInsets.left,
            y: contentOffset.y + safeAreaInsets.top
        )
    }
}
