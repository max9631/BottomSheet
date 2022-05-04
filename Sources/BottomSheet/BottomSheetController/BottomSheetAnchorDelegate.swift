//
//  File.swift
//  
//
//  Created by Adam Salih on 09.02.2021.
//

//class N: UINavigationControllerDelegate {
//    
//}

import UIKit
import InheritableEnum

public class BottomSheetHook<AnchorType: BottomSheetAnchor> {
    private var controller: BottomSheetController
    public var to: AnchorType.ChainType!
    
    public init(controller: BottomSheetController) {
        self.controller = controller
        self.to = AnchorType.chain(with: self)
    }
    
    public func anchor(to anchor: AnchorType, animated: Bool = true) {
        controller.setOffset(offset: anchor.rawValue, animated: animated)
    }
}

extension BottomSheetHook: ChainingDelegate {
    public func recevied<Value>(new value: Value) {
        guard let anchor = value as? AnchorType.RawValue else {
            return
        }
        controller.setOffset(offset: anchor, animated: true)
    }
}

public protocol BottomSheetDelegateBase {
    var offsets: [BottomSheetOffset] { get }
}

public protocol BottomSheetAnchorDelegate: BottomSheetDelegateBase {
    associatedtype AnchorType: BottomSheetAnchor
}

public extension BottomSheetAnchorDelegate {
    var offsets: [BottomSheetOffset] { AnchorType.allInheritedCases }
}

public extension BottomSheetAnchorDelegate where Self: UIViewController {
    var hook: BottomSheetHook<AnchorType>? {
        bottomSheetController
            .flatMap { BottomSheetHook(controller: $0) }
    }
}

public protocol BottomSheetDelegate: BottomSheetAnchorDelegate where AnchorType == BottomSheetDefaultAnchor { }
