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
    var scrollView: UIScrollView? { get }
    var offsets: [BottomSheetOffset] { get }
}

public protocol BottomSheetAnchorDelegate: BottomSheetDelegateBase {
    associatedtype AnchorType: BottomSheetAnchor
}

public extension BottomSheetAnchorDelegate {
    var scrollView: UIScrollView? { nil } // Making it optional to implement
    var offsets: [BottomSheetOffset] { AnchorType.allCases.map(\.offset) }
}

public extension BottomSheetAnchorDelegate where Self: UIViewController {
    var hook: BottomSheetHook<AnchorType>? {
        [navigationController?.parent, parent]
            .first { $0 is BottomSheetController }
            .flatMap { $0 as? BottomSheetController }
            .flatMap { BottomSheetHook(controller: $0) }
    }
}

public protocol BottomSheetDelegate: BottomSheetAnchorDelegate where AnchorType == BottomSheetDefaultAnchor { }
