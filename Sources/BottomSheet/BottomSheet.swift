//
//  File.swift
//  
//
//  Created by Adam Salih on 08.02.2021.
//

import UIKit

protocol BottomSheetDelegate: class {
    var corrdinateSystem: UIView { get }
    var sheetOffset: CGFloat { get }
    
    func setOffset(offset: CGFloat)
}

struct GestureProperties {
    var initialOffset: CGFloat = .zero
}

class BottomSheet: UIView {
//    weak var overlayView: UIView?
    weak var delegate: BottomSheetDelegate?
    
    // gesture properties
    var gesture: GestureProperties = GestureProperties()
    
    init(overlayViewController: UIViewController, delegate: BottomSheetDelegate) {
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
            break
        case .changed:
            delegate.setOffset(offset: gesture.initialOffset + dy)
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
