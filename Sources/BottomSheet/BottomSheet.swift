//
//  File.swift
//  
//
//  Created by Adam Salih on 08.02.2021.
//

import UIKit

protocol BottomSheetPositionDelegate: class {
    var delegate: BottomSheetDelegateBase? { get }
    
    var corrdinateSystem: UIView { get }
    var currentHeight: CGFloat { get }
    
    func setHeight(constant: CGFloat)
    func nearestOffset(for projection: CGFloat) -> BottomSheetOffset
    func setOffset(offset: BottomSheetOffset, animated: Bool, velocity: CGFloat, completion: ((Bool) -> Void)?)
}

struct GestureProperties {
    var initialHeight: CGFloat = .zero
}

class BottomSheet: ContainerView {
    weak var delegate: BottomSheetPositionDelegate?
    
    // gesture properties
    var gesture: GestureProperties = GestureProperties()
    
    override init() {
        super.init()
        setup()
    }
    
    override init(with view: UIView) {
        super.init(with: view)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(BottomSheet.pan(gesture:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        backgroundColor = .systemBackground
    }
    
    @objc
    func pan(gesture recognizer: UIPanGestureRecognizer) {
        guard let delegate = delegate else { return }
        let dy = -recognizer.translation(in: delegate.corrdinateSystem).y
        switch recognizer.state {
        case .began:
            gesture.initialHeight = delegate.currentHeight
        case .ended:
            let velocity = -recognizer.velocity(in: delegate.corrdinateSystem).y // [points/second] - up, + down
            let decelerationRate = UIScrollView.DecelerationRate.fast.rawValue
            let projectedDistance = (velocity / 1000) * decelerationRate / (1.0 - decelerationRate)
            let projection = gesture.initialHeight + dy + projectedDistance
            let nearestOffset = delegate.nearestOffset(for: projection)
            delegate.setOffset(offset: nearestOffset, animated: true, velocity: velocity, completion: nil)
            break
        case .changed:
            delegate.setHeight(constant: gesture.initialHeight + dy)
        default:
            break
        }
    }
}

extension BottomSheet: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
