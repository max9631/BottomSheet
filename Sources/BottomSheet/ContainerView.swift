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
    
    func embedIn(view: UIView, leadingOffset: CGFloat = 0, trailingOffset: CGFloat = 0, topOffset: CGFloat = 0, bottomOffset: CGFloat = 0) {
        embedIn(view: view, insets: .init(top: topOffset, left: leadingOffset, bottom: bottomOffset, right: trailingOffset))
    }
    
    func embedIn(view: UIView, insets: UIEdgeInsets) {
        if presentingView != nil { removePresentingView() }
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right),
            view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
        ])
    }
    
    func removePresentingView() {
        presentingView?.removeFromSuperview()
        presentingView = nil
    }
}
