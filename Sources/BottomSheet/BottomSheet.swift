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
    var sheetOffset: CGFloat { get }
    
    func setConstant(constant: CGFloat)
    func nearestOffset(for projection: CGFloat) -> BottomSheetOffset
    func setOffset(offset: BottomSheetOffset, animated: Bool, velocity: CGFloat, completion: ((Bool) -> Void)?)
}

struct GestureProperties {
    var initialOffset: CGFloat = .zero
}

class BottomSheet: UIView {
//    weak var overlayView: UIView?
    weak var delegate: BottomSheetPositionDelegate?
    
    // gesture properties
    var gesture: GestureProperties = GestureProperties()
    
    init(overlayViewController: UIViewController, delegate: BottomSheetPositionDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        backgroundColor = .white
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(BottomSheet.pan(gesture:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        addSubview(overlayViewController.view)
        guard let overlayView = overlayViewController.view else { return }
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: delegate.corrdinateSystem.safeAreaInsets.bottom)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc
    func pan(gesture recognizer: UIPanGestureRecognizer) {
        guard let delegate = delegate else { return }
        let dy = -recognizer.translation(in: delegate.corrdinateSystem).y
        switch recognizer.state {
        case .began:
            gesture.initialOffset = delegate.sheetOffset
        case .ended:
            let velocity = -recognizer.velocity(in: delegate.corrdinateSystem).y // [points/second] - up, + down
            let decelerationRate = UIScrollView.DecelerationRate.fast.rawValue
            let projectedDistance = (velocity / 1000) * decelerationRate / (1.0 - decelerationRate)
            let projection = gesture.initialOffset + dy + projectedDistance
            let nearestOffset = delegate.nearestOffset(for: projection)
            delegate.setOffset(offset: nearestOffset, animated: true, velocity: velocity, completion: nil)
//            delegate.setOffset(offset: nearestOffset)
            break
        case .changed:
            delegate.setConstant(constant: gesture.initialOffset + dy)
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
