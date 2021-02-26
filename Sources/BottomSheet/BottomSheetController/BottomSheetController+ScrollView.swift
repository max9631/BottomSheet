//
//  File.swift
//  
//
//  Created by Adam Salih on 26.02.2021.
//

import UIKit

extension BottomSheetController {
    public func registerScrollViewDelegate(scrollView: UIScrollView) {
        gestureRouter.registerScrollViewDelegate(scrollView: scrollView)
    }
}
