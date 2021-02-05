//
//  UIViewController+Child.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//

import UIKit
import SnapKit

extension UIViewController {
    func addChildController(_ childController: UIViewController) {
        self.addChild(childController)
        view.addSubview(childController.view)
        childController.didMove(toParent: self)

        childController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func removeChildController(_ childController: UIViewController) {
        childController.parent?.view.accessibilityElements?.removeAll { $0 as? UIView == childController.view }
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
}
