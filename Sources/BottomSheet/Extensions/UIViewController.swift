//
//  File.swift
//  
//
//  Created by Adam Salih on 16.02.2021.
//

import UIKit

extension UIViewController {
    internal var asBottomSheetdelegate: BottomSheetDelegateBase? {
        switch self {
        case let controller as UINavigationController:
            return controller.presentingViewController?.asBottomSheetdelegate
        case let controller as UITabBarController:
            return controller.presentingViewController?.asBottomSheetdelegate
        default:
            return self as? BottomSheetDelegateBase
        }
    }
    
    public var bottomSheetController: BottomSheetController? {
        [navigationController?.parent, tabBarController?.parent, parent]
            .compactMap { $0 as? BottomSheetController }
            .first
    }
}
