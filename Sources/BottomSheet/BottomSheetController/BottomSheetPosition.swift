//
//  File.swift
//  
//
//  Created by Adam Salih on 19.04.2021.
//

import UIKit

public enum PrezentationSide {
    case left, right
}

public enum BottomSheetRegularSizeClassPrezentation {
    case left, right, bottom(side: PrezentationSide)
}

public class BottomSheetPosition {
    public var currentHeight: CGFloat { bottomOffsetConstraint.constant }
    
    public var shouldSetAdditionalMasterSafeAreaInset: Bool = false
    
    public var bottomSheetRegularSizeClassPrezentation: BottomSheetRegularSizeClassPrezentation = .left
    public var bottomSheetRegularSizeClassWidth: CGFloat {
        get { regularWidthConstraint.constant }
        set { regularWidthConstraint.constant = newValue }
    }
    
    var hasSlidablePrezentation: Bool {
        if isRegularSizeClass {
            if case .bottom = bottomSheetRegularSizeClassPrezentation {
                return true
            }
            return false
        }
        return true
    }
    
    private var bottomOffsetConstraint: NSLayoutConstraint
    
    private var compactLeadingConstraint: NSLayoutConstraint
    private var compactTrailingConstraint: NSLayoutConstraint
    private var compactHeightConstraint: NSLayoutConstraint
    private var compactConainerBottomConstraint: NSLayoutConstraint
    
    private var regularWidthConstraint: NSLayoutConstraint
    private var regularTopConstraint: NSLayoutConstraint
    private var regularBottomConstraint: NSLayoutConstraint
    private var regularLeadingOffsetConstraint: NSLayoutConstraint
    private var regularTrailingOffsetConstraint: NSLayoutConstraint
    private var regularLeadingConstraint: NSLayoutConstraint
    private var regularTrailingConstraint: NSLayoutConstraint
    
    private var compactConstraints: [NSLayoutConstraint] {[
        compactLeadingConstraint,
        compactTrailingConstraint,
        bottomOffsetConstraint,
        compactHeightConstraint,
        compactConainerBottomConstraint
    ]}
    
    private var regularLeftConstraints: [NSLayoutConstraint] {[
        regularWidthConstraint,
        regularTopConstraint,
        regularBottomConstraint,
        regularLeadingOffsetConstraint
    ]}
    
    private var regularRightConstraints: [NSLayoutConstraint] {[
        regularWidthConstraint,
        regularTopConstraint,
        regularBottomConstraint,
        regularTrailingOffsetConstraint
    ]}
    
    private var regularBottomLeftConstraints: [NSLayoutConstraint] {[
        regularWidthConstraint,
        regularLeadingConstraint,
        bottomOffsetConstraint,
        compactHeightConstraint,
        compactConainerBottomConstraint
    ]}
    
    private var regularBottomRightConstraints: [NSLayoutConstraint] {[
        regularWidthConstraint,
        regularTrailingConstraint,
        bottomOffsetConstraint,
        compactHeightConstraint,
        compactConainerBottomConstraint
    ]}
    
    private weak var masterViewController: UIViewController? { controller?.masterViewController }
    private weak var controller: BottomSheetController?
    private var currentConstraints: [NSLayoutConstraint] = []
    private var isRegularSizeClass: Bool = false
    
    init(embed bottomSheet: UIView, in controler: BottomSheetController) {
        let view = controler.view!
        self.controller = controler
        let sheet = bottomSheet
        sheet.translatesAutoresizingMaskIntoConstraints = false
        
        regularWidthConstraint = sheet.widthAnchor.constraint(equalToConstant: 320)
        regularTopConstraint = sheet.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        regularBottomConstraint = sheet.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        regularTrailingOffsetConstraint = sheet.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        regularLeadingOffsetConstraint = sheet.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        regularTrailingConstraint = sheet.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        regularLeadingConstraint = sheet.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        
        bottomOffsetConstraint = view.bottomAnchor.constraint(equalTo: sheet.topAnchor, constant: .zero)
        compactHeightConstraint = sheet.heightAnchor.constraint(equalTo: controler.contentFrameView.heightAnchor)
        compactHeightConstraint.priority = .defaultLow
        compactLeadingConstraint = sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        compactTrailingConstraint = sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        compactConainerBottomConstraint = sheet.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor)
    }
    
    func setHeight(constant: CGFloat) {
        updateSafeAreaInsets(constant: constant)
        bottomOffsetConstraint.constant = constant
        regularLeadingOffsetConstraint.constant = constant > 0 ? 16 : -regularWidthConstraint.constant - (controller?.view.safeAreaInsets.left ?? 0)
        regularTrailingOffsetConstraint.constant = constant > 0 ? 16 : -regularWidthConstraint.constant - (controller?.view.safeAreaInsets.right ?? 0)
        
        
    }
    
    func changeHorizontalSizeClass(isRegular: Bool) {
        self.isRegularSizeClass = isRegular
        NSLayoutConstraint.deactivate(currentConstraints)
        currentConstraints = getSuggestedConstraints()
        NSLayoutConstraint.activate(currentConstraints)
        updateSafeAreaInsets()
    }
    
    func updateSafeAreaInsets(constant: CGFloat? = nil) {
        masterViewController?.additionalSafeAreaInsets = { () -> UIEdgeInsets in
            if isRegularSizeClass {
                switch self.bottomSheetRegularSizeClassPrezentation {
                case .left: return .init(top: 0, left: 320 + 16 + 16, bottom: 0, right: 0)
                case .right: return .init(top: 0, left: 0, bottom: 320 + 16 + 16, right: 0)
                case .bottom: return .zero
                }
            } else {
                if self.shouldSetAdditionalMasterSafeAreaInset,
                   let master = self.masterViewController {
                    let constant = constant ?? self.bottomOffsetConstraint.constant
                    let bottom = constant.clamp(from: 0, to: master.view.frame.height/2) - (controller?.view.safeAreaInsets.bottom ?? 0)
                    return.init(top: 0, left: 0, bottom: bottom, right: 0)
                } else {
                    return .zero
                }
            }
        }()
    }
    
    private func getSuggestedConstraints() -> [NSLayoutConstraint] {
        guard isRegularSizeClass else {
            return compactConstraints
        }
        switch self.bottomSheetRegularSizeClassPrezentation {
        case .left: return regularLeftConstraints
        case .right: return regularRightConstraints
        case let .bottom(side):
            switch side {
            case .left: return regularBottomLeftConstraints
            case .right: return regularBottomRightConstraints
            }
        }
    }
}
