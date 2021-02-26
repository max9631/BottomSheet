//
//  File.swift
//  
//
//  Created by Adam Salih on 16.02.2021.
//

import UIKit

internal class ContainerView: UIView {
    weak var presentingView: UIView?
    
    init() {
        super.init(frame: .zero)
    }
    
    init(with view:UIView) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func embedIn(view: UIView, leadingOffset: CGFloat = 0, trailingOffset: CGFloat = 0, topOffset: CGFloat = 0, bottomOffset: CGFloat = 0, bottomPriority: UILayoutPriority = .defaultHigh, maxHeight: NSLayoutAnchor<NSLayoutDimension>? = nil) {
        embedIn(view: view, insets: .init(top: topOffset, left: leadingOffset, bottom: bottomOffset, right: trailingOffset), bottomPriority: bottomPriority, maxHeight: maxHeight)
    }
    
    func embedIn(view: UIView, insets: UIEdgeInsets, bottomPriority: UILayoutPriority = .defaultHigh, maxHeight: NSLayoutAnchor<NSLayoutDimension>? = nil) {
        if presentingView != nil { removePresentingView() }
        self.presentingView = view
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        let bottomConstraint = view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom)
        bottomConstraint.priority = bottomPriority
        var constraints = [
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            bottomConstraint,
        ]
        if let maxHeight = maxHeight {
            let constraint = view.heightAnchor.constraint(lessThanOrEqualTo: maxHeight)
            constraint.priority = .defaultLow
            constraints.append(constraint)
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    func removePresentingView() {
        presentingView?.removeFromSuperview()
        presentingView = nil
    }
}
