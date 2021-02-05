//
//  DrawerViewControllerTyoe.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//

import UIKit
import SnapKit

protocol DrawerViewControllerType: UIViewController {
    var dimmingView: UIView { get }
    var drawerContainerView: UIView { get }
    var drawerTopConstraint: Constraint? { get }
    var contentViewController: UIViewController { get }
    var shouldDismissAnimated: ((Bool) -> Void)? { get set }
    func setupContainerLayout()
    func drawerDidAppear()
}
