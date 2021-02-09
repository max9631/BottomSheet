//
//  File.swift
//  
//
//  Created by Adam Salih on 09.02.2021.
//

import UIKit
public protocol BottomSheetDelegateBase {
    var scrollView: UIScrollView? { get }
    var initialOffset: BottomSheetOffset { get }
    var offsets: [BottomSheetOffset] { get }
}

public protocol BottomSheetDelegate: BottomSheetDelegateBase {
    associatedtype LevelType: BottomSheetLevel
    
    var bottomSheet: BottomSheetController? { get }
    var scrollView: UIScrollView? { get }
    var initialLevel: LevelType { get }
}

public extension BottomSheetDelegate {
    var scrollView: UIScrollView? { nil } // Making it optional to implement
    
    // overrides of its super-protocol
    var initialOffset: BottomSheetOffset { return initialLevel.offset }
    var offsets: [BottomSheetOffset] { LevelType.allCases.map(\.offset) }
    
    // for convenience
    var bottomSheet: BottomSheetController? { nil }
}

public protocol BottomSheetBasicDelegate: BottomSheetDelegate {
    var initialLevel: BottomSheetDefaultLevel { get }
}
