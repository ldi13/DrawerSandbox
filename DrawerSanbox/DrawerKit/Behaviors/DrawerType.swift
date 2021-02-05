//
//  DrawerType.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//

import UIKit

protocol DraggableDrawerDelegate: class {
    func update(to state: DrawerState)
    func drawerConfigurationUpdated()
    func focusOnViewForAccessibility()
}

extension DraggableDrawerDelegate {
    func focusOnViewForAccessibility() {}
}

protocol DraggableDrawerType: class {
    var scrollView: UIScrollView { get }
    var isDraggable: Bool { get }
    var hasMaxPartiallyHeight: Bool { get }
    var heightOfPartiallyExpandedDrawer: CGFloat { get }
    var draggableDrawerDelegate: DraggableDrawerDelegate? { get set }
    func draggableDrawerDidAppear()
}

extension DraggableDrawerType {
    func draggableDrawerDidAppear() {}
}

extension DraggableDrawerType {
    var hasMaxPartiallyHeight: Bool { return true }
}

protocol DraggableDrawerTransitionDelegate: class {
    func yPositionUpdated(_ completion: CGFloat)
    func drawerStateUpdated(_ state: DrawerState)
}

typealias DraggableDrawerViewControllerType = DraggableDrawerType & UIViewController
