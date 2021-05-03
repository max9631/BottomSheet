//
//  File.swift
//  
//
//  Created by Adam Salih on 18.04.2021.
//

import UIKit

extension Comparable {
    func clamp(from: Self, to: Self) -> Self {
        switch self {
        case let x where x < from:
            return from
        case let x where x > to:
            return to
        default:
            return self
        }
    }
}
