//
//  File.swift
//  
//
//  Created by Adam Salih on 09.02.2021.
//

import UIKit

public protocol BottomSheetAnchor: CaseIterable {
    var offset: BottomSheetOffset { get }
}

public enum BottomSheetDefaultAnchor: BottomSheetAnchor {
    case min, med, max
    
    public var offset: BottomSheetOffset {
        switch self {
        case .max: return .relative(percentage: 1)
        case .med: return .relative(percentage: 0.45)
        case .min: return .specific(offset: 100)
        }
    }
}

public enum BottomSheetOffset {
    case relative(percentage: CGFloat, offsettedBy: CGFloat = 0)
    case specific(offset: CGFloat)
}
