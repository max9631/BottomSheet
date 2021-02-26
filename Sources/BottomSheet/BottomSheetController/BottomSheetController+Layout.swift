//
//  File.swift
//  
//
//  Created by Adam Salih on 26.02.2021.
//

import UIKit

// MARK: - Layout definition
extension BottomSheetController {
    func setupComposition() {
        view.addSubview(contentFrameView)
        view.addSubview(masterContainer)
        view.addSubview(bottomSheet)
        createContentViewLayout()
        createMasterContainer()
        createBottomSheetLayout()
        view.sendSubviewToBack(masterContainer)
        view.sendSubviewToBack(contentFrameView)
    }
}

private extension BottomSheetController {
    func createContentViewLayout() {
        let contentView = contentFrameView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func createMasterContainer() {
        let masterView = masterContainer
        masterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(masterView)
        NSLayoutConstraint.activate([
            masterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            masterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            masterView.topAnchor.constraint(equalTo: view.topAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func createBottomSheetLayout() {
        let sheet = bottomSheet
        sheet.addGestureRecognizer(gestureRouter.slideGestureRecognizer)
        sheet.translatesAutoresizingMaskIntoConstraints = false
        regularConstraints = [
            sheet.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            sheet.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            sheet.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            sheet.widthAnchor.constraint(equalToConstant: 320)
        ]
        let bottomSheetOffset = view.bottomAnchor.constraint(equalTo: sheet.topAnchor, constant: initialHeight)
        self.bottomSheetOffsetConstraint = bottomSheetOffset
        let heightConstraint = sheet.heightAnchor.constraint(equalTo: contentFrameView.heightAnchor)
        heightConstraint.priority = .defaultLow
        compactConstraints = [
            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetOffset,
            heightConstraint,
            sheet.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor)
        ]
        changeLayoutIfNeeded()
    }
}
