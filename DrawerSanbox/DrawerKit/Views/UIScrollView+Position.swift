//
//  UIScrollView+Position.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//

import UIKit

extension UIScrollView {
    var isAtTop: Bool {
        return contentOffset.y <= 0
    }

    var isAtBottom: Bool {
        return contentOffset.y >= contentSize.height
    }

    var isScrolling: Bool {
        return isDragging && !isDecelerating || isTracking
    }
}
