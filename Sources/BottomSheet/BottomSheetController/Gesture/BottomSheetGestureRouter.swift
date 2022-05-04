//
//  File.swift
//  
//
//  Created by Adam Salih on 26.02.2021.
//

import UIKit

class BottomSheetGestureRouter: NSObject {
    weak var delegate: BottomSheetSlideGestureDelegate? {
        didSet {
            slideGesture.delegate = delegate
            scrollGesture.delegate = delegate
        }
    }
    
    lazy var slideGestureRecognizer: UIPanGestureRecognizer = createGesture(selector: #selector(slide))
    private weak var scrollViewGestureRecognizer: UIPanGestureRecognizer?
    
    private var slideGesture: BottomSheetSlideGesture = .init()
    private var scrollGesture: BottomSheetSrollGesture = .init()
    
    private func createGesture(selector: Selector) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer(target: self, action: selector)
        recognizer.delegate = self
        return recognizer
    }
    
    func registerScrollViewDelegate(scrollView: UIScrollView) {
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(scroll))
        scrollViewGestureRecognizer = scrollView.panGestureRecognizer
        scrollGesture.scrollView = scrollView
    }
}

extension BottomSheetGestureRouter {
    @objc
    func slide(gesture recognizer: UIPanGestureRecognizer) {
        guard delegate?.position.hasSlidablePrezentation != false else {
            return
        }
        slideGesture.slide(gesutre: recognizer)
    }
}

extension BottomSheetGestureRouter {
    @objc
    func scroll(gesture recognizer: UIPanGestureRecognizer) {
        guard delegate?.position.hasSlidablePrezentation != false else {
            return
        }
        scrollGesture.scroll(gesture: recognizer)
    }
}

extension BottomSheetGestureRouter: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let delegate = delegate,
              let otherPanGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer,
              otherPanGestureRecognizer == scrollViewGestureRecognizer else {
            return false
        }
        if delegate.position.hasSlidablePrezentation,
           delegate.position.currentHeight != delegate.maxHeightConstant {
                return true
        }
        return false
    }
}
