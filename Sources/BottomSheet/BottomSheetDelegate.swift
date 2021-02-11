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
public protocol BottomSheetDelegateBase {
    
    var scrollView: UIScrollView? { get }
//    var initialOffset: BottomSheetOffset { get }
    var offsets: [BottomSheetOffset] { get }
}

public protocol BottomSheetLevelDelegate: BottomSheetDelegateBase {
    associatedtype LevelType: BottomSheetLevel
    
    var bottomSheet: BottomSheetController<LevelType>? { get }
    var scrollView: UIScrollView? { get }
//    var initialLevel: LevelType { get }
}

public extension BottomSheetLevelDelegate {
    var scrollView: UIScrollView? { nil } // Making it optional to implement
    
    // overrides of its super-protocol
//    var initialOffset: BottomSheetOffset { return initialLevel.offset }
    var offsets: [BottomSheetOffset] { LevelType.allCases.map(\.offset) }
    
    // for convenience
    var bottomSheet: BottomSheetController<LevelType>? { nil }
}

public extension BottomSheetLevelDelegate where Self: UIViewController {
    var bottomSheet: BottomSheetController<LevelType>? {
        [navigationController?.view.superview, view.superview]
            .compactMap { $0 as? BottomSheet }
            .compactMap { $0.delegate as? BottomSheetController }
            .first
    }
}

public protocol BottomSheetDelegate: BottomSheetLevelDelegate {
    var initialLevel: BottomSheetDefaultLevel { get }
}
