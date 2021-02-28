//
//  File.swift
//  
//
//  Created by Adam Salih on 26.02.2021.
//

import UIKit

struct BottomSheetSrollGesture{
    weak var delegate: BottomSheetSlideGestureDelegate?
    weak var scrollView: UIScrollView?
    
    private var lastContentOffset: CGFloat = .zero
    private var isSliding: Bool = false
    private var slideGesture: BottomSheetSlideGesture?
    
    private var initialHeight: CGFloat = .zero
    private var activationLocation: CGFloat = .zero
    
    init(delegate: BottomSheetSlideGestureDelegate? = nil, scrollView: UIScrollView? = nil) {
        self.delegate = delegate
        self.scrollView = scrollView
    }
    
    private var isInSlideState: Bool {
        true
        
    }
    
    
    mutating func scroll(gesture recognizer: UIPanGestureRecognizer) {
        print(scrollView?.normalizedContentOffset.y)
        guard let scrollView = scrollView, let delegate = delegate else {
            return
        }
        let contentOffset = scrollView.normalizedContentOffset.y
        switch recognizer.state {
        case .changed, .began:
            if contentOffset < 0 && lastContentOffset >= 0 {
                isSliding = true
                initialHeight = delegate.currentHeight
                activationLocation = recognizer.location(in: delegate.corrdinateSystem).y
            } else if isSliding && contentOffset >= 0 {
                isSliding = false
                slideGesture = nil
            }
            if isSliding {
                scrollView.contentOffset.y = -scrollView.safeAreaInsets.top
                let currentLocation = recognizer.location(in: delegate.corrdinateSystem).y
                let translation = activationLocation - currentLocation
                delegate.setHeight(constant: initialHeight + translation)
            }
        case .ended:
            isSliding = false
            
        default:
            break
        }
        lastContentOffset = contentOffset
    }
}
