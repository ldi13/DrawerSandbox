//
//  DrawerViewController+Properties.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 4/2/21.
//

import UIKit

extension DrawerViewController {
    var containerViewBounds: CGRect {
        return passThroughView.bounds
    }

    var containerViewSize: CGSize {
        return containerViewBounds.size
    }

    var containerViewHeight: CGFloat {
        return containerViewSize.height
    }

    var expandedViewHeight: CGFloat {
        return containerViewHeight - drawerFullY
    }
}

extension DraggableDrawerViewController {
    var panGesturePercentage: CGFloat {
        let offsetWithPartial = drawerPartialY - currentDrawerY
        let totalDistance = expandedViewHeight - drawerPartialHeight
        return min(max(offsetWithPartial, 0) / totalDistance, 1)
    }

    var drawerPartialHeight: CGFloat {
        let safeAreaBottomOffset = max(UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets.bottom ?? 0, 20)

        let maxPartialHeight = draggableViewController.hasMaxPartiallyHeight ? expandedViewHeight * Constants.maxPartialHeightRatio : CGFloat.greatestFiniteMagnitude
        let contentViewHeight = draggableViewController.heightOfPartiallyExpandedDrawer

        let drawerViewAdditionalInsets = containerView.headerView.frame.maxY + safeAreaBottomOffset
        let drawerPartialH = min(contentViewHeight + drawerViewAdditionalInsets, maxPartialHeight)
        return GeometryResolver.drawerPartialH(drawerPartialHeight: drawerPartialH,
                                               containerViewHeight: containerViewHeight)

    }

    var drawerPartialY: CGFloat {
        return GeometryResolver.drawerPartialY(drawerPartialHeight: drawerPartialHeight,
                                               containerViewHeight: containerViewHeight)
    }

    var currentDrawerState: DrawerState {
        get {
            return GeometryResolver.drawerState(for: currentDrawerY,
                                                drawerPartialHeight: drawerPartialHeight,
                                                containerViewHeight: containerViewHeight,
                                                drawerFullY: drawerFullY)
        }

        set {
            currentDrawerY =
                GeometryResolver.drawerPositionY(for: newValue,
                                                 drawerPartialHeight: drawerPartialHeight,
                                                 containerViewHeight: containerViewHeight,
                                                 drawerFullY: drawerFullY)
        }
    }

    var currentDrawerY: CGFloat {
        get {
            let value = min(max(containerView.frame.origin.y, drawerFullY), containerViewHeight)
            return value
        }

        set {
            let posY = min(max(newValue, drawerFullY), containerViewHeight)
            drawerTopConstraint?.update(offset: posY)
        }
    }
}
