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

extension BottomSheetController {
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
        bottomSheet.addGestureRecognizer(gestureRouter.slideGestureRecognizer)
        changeLayoutIfNeeded()
    }
}
