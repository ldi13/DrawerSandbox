//
//  DrawerContentViewController.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 4/2/21.
//

import Foundation
import UIKit

final class DrawerContentViewController: UIViewController {
    private var contentViewController: DraggableDrawerViewControllerType

    // MARK: - Initializers

    init(contentViewController: DraggableDrawerViewControllerType) {
        self.contentViewController = contentViewController

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        addChildController(contentViewController)
    }

    func updateContentViewController(_ contentViewController: DraggableDrawerViewControllerType) {
        addChildController(contentViewController)

        contentViewController.draggableDrawerDelegate = self.contentViewController.draggableDrawerDelegate

        DispatchQueue.main.async {
            self.removeChildController(self.contentViewController)
            self.contentViewController = contentViewController
            self.draggableDrawerDelegate?.drawerConfigurationUpdated()
        }
    }
}

extension DrawerContentViewController: DraggableDrawerType {
    var scrollView: UIScrollView {
        return contentViewController.scrollView
    }

    var isDraggable: Bool {
        return contentViewController.isDraggable
    }

    var hasMaxPartiallyHeight: Bool {
        return contentViewController.hasMaxPartiallyHeight
    }

    var heightOfPartiallyExpandedDrawer: CGFloat {
        return contentViewController.heightOfPartiallyExpandedDrawer
    }

    var draggableDrawerDelegate: DraggableDrawerDelegate? {
        set {
            contentViewController.draggableDrawerDelegate = newValue
        }

        get {
            return contentViewController.draggableDrawerDelegate
        }
    }

    func draggableDrawerDidAppear() {
        contentViewController.draggableDrawerDelegate?.focusOnViewForAccessibility()
    }
}

extension DrawerContentViewController: DraggableDrawerTransitionDelegate {
    func yPositionUpdated(_ completion: CGFloat) {
        (contentViewController as? DraggableDrawerTransitionDelegate)?.yPositionUpdated(completion)
    }

    func drawerStateUpdated(_ state: DrawerState) {
        (contentViewController as? DraggableDrawerTransitionDelegate)?.drawerStateUpdated(state)
    }
}
