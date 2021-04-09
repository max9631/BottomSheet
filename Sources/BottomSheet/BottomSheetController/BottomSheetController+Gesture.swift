//
//  File.swift
//  
//
//  Created by Adam Salih on 26.02.2021.
//

import UIKit

// MARK: BottomSheetPositionDelegate
extension BottomSheetController: BottomSheetSlideGestureDelegate {
    
    // Computed properties
    internal var delegate: BottomSheetDelegateBase? {
        contextViewControllers.first?.asBottomSheetdelegate
    }
    
    internal var offsets: [BottomSheetOffset] {
        delegate?.offsets ?? BottomSheetDefaultAnchor.allCases.map(\.offset)
    }
    
    var corrdinateSystem: UIView { view }
    
    
    var maxHeightConstant: CGFloat {
        guard let delegate = delegate,
              let index = delegate.offsets
                .enumerated()
                .map({ (index, offset) in
                    return (index, constant(for: offset))
                })
                .max(by: { (max, next) -> Bool in
                    return max.1 < next.1
                })?.0 else {
            return constant(for: BottomSheetDefaultAnchor.max.offset)
        }
        return constant(for: delegate.offsets[index])
    }
    
    internal func constant(for offset: BottomSheetOffset) -> CGFloat {
        let constant: CGFloat = {
            switch offset {
            case let .specific(offset): return offset
            case let .relative(percentage, offsettedBy):
                return (maxContentHeight * percentage) + offsettedBy
            }
        }()
        if let maxHeight = bottomSheet.presentingView?.frame.height, constant > maxHeight {
            return maxHeight
        }
        return constant
    }
    
    func setHeight(constant: CGFloat) {
        guard let constraint = bottomSheetOffsetConstraint else {
            initialHeight = constant
            return
        }
        constraint.constant = constant
    }
    
    public func setOffset(offset: BottomSheetOffset, animated: Bool = true, velocity: CGFloat = 0, completion: ((Bool) -> Void)? = nil) {
        let closure = {
            self.setHeight(constant: self.constant(for: offset))
            self.view.layoutIfNeeded()
        }
        guard animated else {
            closure()
            completion?(false)
            return
        }
        var distance = constant(for: offset) - currentHeight
        distance = distance == 0 ? 1 : distance
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            usingSpringWithDamping: velocity == 0 ? 1 : 0.7,
            initialSpringVelocity: distance == 0 ? velocity : velocity / distance,
            options: .allowUserInteraction,
            animations: closure,
            completion: completion
        )
    }
    
    func nearestOffset(for projection: CGFloat) -> BottomSheetOffset {
        let offsets = self.offsets
        let index = offsets
            .map(constant(for:))
            .enumerated()
            .map { index, offset in (index, abs(offset - projection)) }
            .min { $0.1 < $1.1 }?.0
        return index != nil ? offsets[index!] : .specific(offset: initialHeight)
    }
}