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
    
    lazy var slideGestureRecognizer: UIPanGestureRecognizer = { createGesture(selector: #selector(slide)) }()
    lazy var scrollGestureRecognizer: UIPanGestureRecognizer = { createGesture(selector: #selector(scroll)) }()
    
    private var slideGesture: BottomSheetSlideGesture = .init()
    private var scrollGesture: BottomSheetSrollGesture = .init()
    
    private func createGesture(selector: Selector) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer(target: self, action: selector)
        recognizer.delegate = self
        return recognizer
    }
    
    func registerScrollViewDelegate(scrollView: UIScrollView) {
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(scroll))
        scrollGesture.scrollView = scrollView
    }
}

extension BottomSheetGestureRouter {
    @objc
    func slide(gesture recognizer: UIPanGestureRecognizer) {
        slideGesture.slide(gesutre: recognizer)
    }
}

extension BottomSheetGestureRouter {
    @objc
    func scroll(gesture recognizer: UIPanGestureRecognizer) {
        scrollGesture.scroll(gesture: recognizer)
    }
}

extension BottomSheetGestureRouter: UIGestureRecognizerDelegate {
    
}
