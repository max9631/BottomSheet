//
//  File.swift
//  
//
//  Created by Adam Salih on 09.02.2021.
//

import UIKit
import InheritableEnum

public protocol BottomSheetAnchor: Inheritable, CaseIterable where RawValue == BottomSheetOffset  {

    static var allInheritedCases: [BottomSheetOffset] { get }
}

public extension BottomSheetAnchor {
    static var allInheritedCases: [BottomSheetOffset] { allCases.map(\.rawValue) }

    init?(rawValue: BottomSheetOffset) { nil }
}

public extension BottomSheetAnchor where Inherites: BottomSheetAnchor {
    static var allInheritedCases: [BottomSheetOffset] {
        let selfCases: [BottomSheetOffset] = allCases.map(\.rawValue)
        return Inherites.allInheritedCases + selfCases
    }
}

public enum BottomSheetDefaultAnchor: BottomSheetAnchor {
    case min, med, max

    public var rawValue: BottomSheetOffset {
        switch self {
        case .max: return .relative(percentage: 1)
        case .med: return .relative(percentage: 0.45)
        case .min: return .specific(offset: 100)
        }
    }
}

public enum BottomSheetAnchorHidable: BottomSheetAnchor {
    case hidden

    public var rawValue: BottomSheetOffset {
        switch self {
        case .hidden: return .relative(percentage: 0)
        }
    }
}

public enum BottomSheetOffset {
    case relative(percentage: CGFloat, offsettedBy: CGFloat = 0)
    case specific(offset: CGFloat)
}
