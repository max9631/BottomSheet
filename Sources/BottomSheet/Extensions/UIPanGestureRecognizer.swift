//
//  File.swift
//  
//
//  Created by Adam Salih on 15.03.2021.
//

import UIKit

struct PanGestureDirection {
    enum VerticalDirection {
        case up, down
    }

    enum HorizontalDirection {
        case left, right
    }

    let horizontal: HorizontalDirection
    let vertical: VerticalDirection
}

extension UIPanGestureRecognizer {
    func direction(in view: UIView) -> PanGestureDirection {
        let translation = self.translation(in: view)
        return PanGestureDirection(
            horizontal: translation.x >= 0 ? .right : .left,
            vertical: translation.y >= 0 ? .down : .up
        )
    }
}
