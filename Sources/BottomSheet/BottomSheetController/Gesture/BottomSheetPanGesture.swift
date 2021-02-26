//
//  File.swift
//  
//
//  Created by Adam Salih on 25.02.2021.
//

import UIKit

protocol BottomSheetSlideGestureDelegate: class {
    var delegate: BottomSheetDelegateBase? { get }
    
    var corrdinateSystem: UIView { get }
    var currentHeight: CGFloat { get }
    
    func setHeight(constant: CGFloat)
    func nearestOffset(for projection: CGFloat) -> BottomSheetOffset
    func setOffset(offset: BottomSheetOffset, animated: Bool, velocity: CGFloat, completion: ((Bool) -> Void)?)
}

struct BottomSheetSlideGesture {
    
    weak var delegate: BottomSheetSlideGestureDelegate?
    
    private var initialHeight: CGFloat = .zero
    
    mutating func slide(gesutre recognizer: UIPanGestureRecognizer) {
        guard let delegate = delegate else { return }
        let dy = -recognizer.translation(in: delegate.corrdinateSystem).y
        switch recognizer.state {
        case .began:
            initialHeight = delegate.currentHeight
        case .ended:
            let velocity = -recognizer.velocity(in: delegate.corrdinateSystem).y // [points/second] - up, + down
            let decelerationRate = UIScrollView.DecelerationRate.fast.rawValue
            let projectedDistance = (velocity / 1000) * decelerationRate / (1.0 - decelerationRate)
            let projection = initialHeight + dy + projectedDistance
            let nearestOffset = delegate.nearestOffset(for: projection)
            delegate.setOffset(offset: nearestOffset, animated: true, velocity: velocity, completion: nil)
            break
        case .changed:
            delegate.setHeight(constant: initialHeight + dy)
        default:
            break
        }
    }
}
