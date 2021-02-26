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
        let activateRegular = isRegularSizeClass
        NSLayoutConstraint.deactivate(activateRegular ? compactConstraints : regularConstraints)
        NSLayoutConstraint.activate(activateRegular ? regularConstraints : compactConstraints)
        updateSafeAreaInsets()
    }
    
    func updateSafeAreaInsets() {
        if isRegularSizeClass {
            masterViewController?.additionalSafeAreaInsets = .init(top: 0, left: 320 + 16 + 16, bottom: 0, right: 0)
        } else {
            masterViewController?.additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func showMaster(with viewController: UIViewController) {
        if let master = masterViewController {
            master.willMove(toParent: nil)
            master.view.removeFromSuperview()
            master.removeFromParent()
        }
        addChild(viewController)
        masterViewController = viewController
        masterContainer.embedIn(view: viewController.view)
        viewController.didMove(toParent: self)
    }
    
    func showBottomSheet(with viewController: UIViewController) {
        pushContext(viewController: viewController)
    }
    
    func pushContext(viewController: UIViewController) {
        contextViewControllers.append(viewController)
        addChild(viewController)
        setOffset(offset: .specific(offset: 0)) { _ in
            self.bottomSheet.embedIn(view: viewController.view, bottomPriority: .defaultLow - 10, maxHeight: self.contentFrameView.heightAnchor)
            self.setOffset(offset: .specific(offset: self.initialHeight))
        }
        viewController.didMove(toParent: self)
        setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: .compact), forChild: viewController)
    }
    
    func popContext() {
        guard !contextViewControllers.isEmpty else { return }
        let controller = contextViewControllers.popLast()
        setOffset(offset: .specific(offset: 0)) { _ in
            controller?.willMove(toParent: nil)
            controller?.view.removeFromSuperview()
            controller?.removeFromParent()
            if let previousController = self.contextViewControllers.last {
                self.bottomSheet.embedIn(view: previousController.view, bottomPriority: .defaultLow - 10, maxHeight: self.contentFrameView.heightAnchor)
            }
        }
    }
}
