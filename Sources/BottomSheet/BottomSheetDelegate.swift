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

public struct BottomSheetControllerInterface<LevelType: BottomSheetAnchorPoint> {
    private var controller: BottomSheetController
    
    public init(controller: BottomSheetController) {
        self.controller = controller
    }
    
    public func set(level: LevelType, animated: Bool = true) {
        controller.setOffset(offset: level.offset, animated: animated)
    }
}

public protocol BottomSheetDelegateBase {
    var scrollView: UIScrollView? { get }
    var offsets: [BottomSheetOffset] { get }
}

public protocol BottomSheetAnchorTypeDelegate: BottomSheetDelegateBase {
    associatedtype LevelType: BottomSheetAnchorPoint
    
    var bottomSheet: BottomSheetController? { get }
    var scrollView: UIScrollView? { get }
}

public extension BottomSheetAnchorTypeDelegate {
    var scrollView: UIScrollView? { nil } // Making it optional to implement
    var offsets: [BottomSheetOffset] { LevelType.allCases.map(\.offset) }
    var bottomSheet: BottomSheetController? { nil }
}

public extension BottomSheetAnchorTypeDelegate where Self: UIViewController {
    var bottomSheet: BottomSheetControllerInterface<LevelType>? {
        [navigationController?.parent, parent]
            .compactMap { $0 as? BottomSheetController }
            .first
            .flatMap { BottomSheetControllerInterface(controller: $0) }
    }
}

public protocol BottomSheetDelegate: BottomSheetAnchorTypeDelegate where LevelType == BottomSheetDefaultLevel { }
