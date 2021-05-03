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

public struct BottomSheetHook<AnchorType: BottomSheetAnchor> {
    private var controller: BottomSheetController
    
    public init(controller: BottomSheetController) {
        self.controller = controller
    }
    
    public func anchor(to anchor: AnchorType, animated: Bool = true) {
        controller.setOffset(offset: anchor.offset, animated: animated)
    }
}

public protocol BottomSheetDelegateBase {
    var offsets: [BottomSheetOffset] { get }
}

public protocol BottomSheetAnchorDelegate: BottomSheetDelegateBase {
    associatedtype AnchorType: BottomSheetAnchor
}

public extension BottomSheetAnchorDelegate {
    var offsets: [BottomSheetOffset] { AnchorType.allCases.map(\.offset) }
}

public extension BottomSheetAnchorDelegate where Self: UIViewController {
    var hook: BottomSheetHook<AnchorType>? {
        bottomSheetController
            .flatMap { BottomSheetHook(controller: $0) }
    }
}

public protocol BottomSheetDelegate: BottomSheetAnchorDelegate where AnchorType == BottomSheetDefaultAnchor { }
