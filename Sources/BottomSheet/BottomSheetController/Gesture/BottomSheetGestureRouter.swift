//
//  File.swift
//  
//
//  Created by Adam Salih on 26.02.2021.
//

import UIKit

class BottomSheetGestureRouter: NSObject {
    weak var delegate: BottomSheetSlideGestureDelegate?
    
    lazy var slideGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(slide))
        recognizer.delegate = self
        return recognizer
    }()
    
    lazy var scrollGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(scroll))
        recognizer.delegate = self
        return recognizer
    }()
    
    private weak var scrollView: UIScrollView?
    
    private var slideGesture: BottomSheetSlideGesture?
    
    
    func registerScrollViewDelegate(scrollView: UIScrollView) {
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(scroll))
        self.scrollView = scrollView
    }
}

extension BottomSheetGestureRouter {
    @objc
    func slide(gesture recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            slideGesture = .init()
            slideGesture?.delegate = delegate
        case .ended:
            slideGesture?.slide(gesutre: recognizer)
            slideGesture = nil
        default:
            break;
        }
        slideGesture?.slide(gesutre: recognizer)
    }
}

extension BottomSheetGestureRouter {
    @objc
    func scroll(gesture recognizer: UIPanGestureRecognizer) {
        print(scrollView?.normalizedContentOffset)
        if scrollView?.normalizedContentOffset.y <= 0 {
            scrollView
        }
    }
}

extension BottomSheetGestureRouter: UIGestureRecognizerDelegate {
    
}
