//
//  PassThroughView.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//

import UIKit

class PassThroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        // If the tap is not catched by one of our subviews we forward it to our parent
        if hitView == self {
            return nil
        }

        return hitView
    }
}
