//
//  File.swift
//  
//
//  Created by Adam Salih on 09.02.2021.
//

import UIKit

public protocol BottomSheetLevel: CaseIterable {
    var offset: BottomSheetOffset { get }
}

public enum BottomSheetDefaultLevel: BottomSheetLevel {
    case min, med, max
    
    public var offset: BottomSheetOffset {
        switch self {
        case .max: return .relative(percentage: 1)
        case .med: return .relative(percentage: 0.5)
        case .min: return .specific(offset: 200)
        }
    }
}

public enum BottomSheetOffset {
    case relative(percentage: CGFloat, offsettedBy: CGFloat = 0)
    case specific(offset: CGFloat)
}
