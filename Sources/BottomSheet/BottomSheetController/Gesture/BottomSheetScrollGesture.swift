//
//  File.swift
//  
//
//  Created by Adam Salih on 26.02.2021.
//

import UIKit

class BottomSheetSrollGesture {
    weak var delegate: BottomSheetSlideGestureDelegate?
    weak var scrollView: UIScrollView? {
        didSet { maxHeight = delegate?.maxHeightConstant ?? .zero }
    }
    
    private var lastContentOffset: CGFloat = .zero
    private var slideGesture: BottomSheetSlideGesture?
    
    private var initialHeight: CGFloat = .zero
    private var initialContentOffset: CGPoint = .zero
    private var activationLocation: CGFloat = .zero
    
    private var maxHeight: CGFloat = .zero
    
    init(delegate: BottomSheetSlideGestureDelegate? = nil, scrollView: UIScrollView? = nil) {
        self.delegate = delegate
        self.scrollView = scrollView
    }
    
    private var wasInSlideState: Bool = false
    
    private func calculateSlideStateFor(upDirection: Bool) -> Bool {
        guard let delegate = delegate else { return false }
        guard let scrollView = scrollView else { return true }
        let topOffset = scrollView.normalizedContentOffset
        return !upDirection && topOffset.y <= 0
            || delegate.position.currentHeight < maxHeight
    }
    
    
    func scroll(gesture recognizer: UIPanGestureRecognizer) {
        guard let scrollView = scrollView, let delegate = delegate else {
            return
        }
        let contentOffset = scrollView.normalizedContentOffset.y
        let translation = -recognizer.translation(in: delegate.corrdinateSystem).y
        let isInSlideState = calculateSlideStateFor(upDirection: translation >= 0)
        switch recognizer.state {
        case .began:
            fallthrough
        case .changed:
            let justStartedSliding = isInSlideState && !wasInSlideState
//            let justEndedSliding = !isInSlideState && wasInSlideState
            if justStartedSliding {
                initialHeight = delegate.position.currentHeight
                activationLocation = recognizer.location(in: delegate.corrdinateSystem).y
                initialContentOffset = scrollView.contentOffset
            }
            
            if isInSlideState {
                scrollView.contentOffset.y = initialContentOffset.y
                let currentLocation = recognizer.location(in: delegate.corrdinateSystem).y
                let translation = activationLocation - currentLocation
                delegate.position.setHeight(constant: initialHeight + translation)
            }
        case .ended:
            if isInSlideState {
                let velocity = -recognizer.velocity(in: delegate.corrdinateSystem).y // [points/second] - up, + down
                let decelerationRate = UIScrollView.DecelerationRate.fast.rawValue
                let projectedDistance = (velocity / 1000) * decelerationRate / (1.0 - decelerationRate)
                let projection = initialHeight + translation + projectedDistance
                let nearestOffset = delegate.nearestOffset(for: projection)
                delegate.setOffset(offset: nearestOffset, animated: true, velocity: velocity, completion: nil)
            }
            wasInSlideState = false
            return
        default:
            break
        }
        lastContentOffset = contentOffset
        wasInSlideState = isInSlideState
    }
}
