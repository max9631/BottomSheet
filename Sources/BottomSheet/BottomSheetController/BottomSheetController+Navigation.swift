//
//  File.swift
//  
//
//  Created by Adam Salih on 26.02.2021.
//

import UIKit

// MARK: - Navigation interface
public extension BottomSheetController {
    func changeLayoutIfNeeded() {
        position.changeHorizontalSizeClass(isRegular: isRegularSizeClass)
    }
    
    func showMaster(with viewController: UIViewController) {
        if let master = masterViewController, master != viewController {
            master.willMove(toParent: nil)
            master.view.removeFromSuperview()
            master.removeFromParent()
        }
        addChild(viewController)
        masterViewController = viewController
        masterContainer.embedIn(view: viewController.view)
        viewController.didMove(toParent: self)
    }
    
    func showBottomSheet(with viewController: UIViewController, at offset: BottomSheetOffset? = nil, animated: Bool) {
        pushContext(viewController: viewController, at: offset, animated: animated)
    }
    
    func repalceContext(with viewController: UIViewController, at offset: BottomSheetOffset? = nil, animated: Bool) {
        guard !contextViewControllers.isEmpty else { return }
        let controller = contextViewControllers.popLast()
        setOffset(offset: .specific(offset: 0)) { _ in
            controller?.willMove(toParent: nil)
            controller?.view.removeFromSuperview()
            controller?.removeFromParent()
            self.contextViewControllers.append(viewController)
            self.addChild(viewController)
            self.bottomSheet.embedIn(view: viewController.view, bottomPriority: .defaultLow - 10, maxHeight: self.contentFrameView.heightAnchor)
            if let offset = offset {
                self.setOffset(offset: offset, animated: animated)
            }
            viewController.didMove(toParent: self)
            self.setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: .compact), forChild: viewController)
        }
    }
    
    func pushContext(viewController: UIViewController, forceHeightBasedOnMaxAnchor: Bool = false, at offset: BottomSheetOffset? = nil, animated: Bool, completion: (() -> Void)? = nil) {
        self.contextViewControllers.append(viewController)
        self.addChild(viewController)
        setOffset(offset: .specific(offset: 0), animated: animated) { _ in
            self.bottomSheet.embedIn(view: viewController.view, bottomPriority: .defaultLow - 10, maxHeight: self.contentFrameView.heightAnchor)
            if forceHeightBasedOnMaxAnchor {
                viewController.view.heightAnchor.constraint(equalToConstant: self.maxHeightConstantUnlimited).isActive = true
            }
            self.bottomSheet.layoutIfNeeded()
            if let offset = offset {
                self.setOffset(offset: offset, animated: animated) { _ in
                    completion?()
                }
            } else {
                completion?()
            }
        }
        viewController.didMove(toParent: self)
        setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: .compact), forChild: viewController)
    }
    
    func popContext(count: Int = 1, completion: (() -> Void)? = nil) {
        guard !contextViewControllers.isEmpty else { return }
        var popedVC: [UIViewController?] = []
        for _ in 0..<count {
            let controller = contextViewControllers.popLast()
            popedVC.append(controller)
        }
        setOffset(offset: .specific(offset: 0)) { _ in
            popedVC.forEach { controller in
                controller?.willMove(toParent: nil)
                controller?.view.removeFromSuperview()
                controller?.removeFromParent()
            }
            if let previousController = self.contextViewControllers.last {
                self.bottomSheet.embedIn(view: previousController.view, bottomPriority: .defaultLow - 10, maxHeight: self.contentFrameView.heightAnchor)
            }
            completion?()
        }
    }
}
