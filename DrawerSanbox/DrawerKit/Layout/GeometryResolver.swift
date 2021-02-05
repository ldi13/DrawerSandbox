//
//  GeometryResolver.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//

import UIKit

struct GeometryResolver {
    static func drawerPartialH(drawerPartialHeight: CGFloat,
                               containerViewHeight: CGFloat) -> CGFloat {
        return min(max(0, drawerPartialHeight), containerViewHeight)
    }

    static func drawerPartialY(drawerPartialHeight: CGFloat,
                               containerViewHeight: CGFloat) -> CGFloat {
        let partialH = drawerPartialH(drawerPartialHeight: drawerPartialHeight,
                                      containerViewHeight: containerViewHeight)
        return containerViewHeight - partialH
    }

    static func clamped(_ positionY: CGFloat,
                        drawerPartialHeight: CGFloat,
                        containerViewHeight: CGFloat,
                        drawerFullY: CGFloat) -> CGFloat {
        let partialY = drawerPartialY(drawerPartialHeight: drawerPartialHeight,
                                      containerViewHeight: containerViewHeight)

        if smallerThanOrEqual(positionY, partialY) {
            return drawerFullY
        } else {
            return partialY
        }
    }
}

extension GeometryResolver {
    static func drawerState(for positionY: CGFloat,
                            drawerPartialHeight: CGFloat,
                            containerViewHeight: CGFloat,
                            drawerFullY: CGFloat) -> DrawerState {
        if smallerThanOrEqual(positionY, drawerFullY) { return .fullyExpanded }
        if greaterThanOrEqual(positionY, containerViewHeight) { return .partiallyExpanded }

        let partialY = drawerPartialY(drawerPartialHeight: drawerPartialHeight,
                                      containerViewHeight: containerViewHeight)
        if equal(positionY, partialY) { return .partiallyExpanded }

        let posY = clamped(positionY,
                           drawerPartialHeight: drawerPartialHeight,
                           containerViewHeight: containerViewHeight,
                           drawerFullY: drawerFullY)

        return drawerState(for: posY,
                           drawerPartialHeight: drawerPartialHeight,
                           containerViewHeight: containerViewHeight,
                           drawerFullY: drawerFullY)
    }

    static func drawerPositionY(for state: DrawerState,
                                drawerPartialHeight: CGFloat,
                                containerViewHeight: CGFloat,
                                drawerFullY: CGFloat) -> CGFloat {
        switch state {
        case .partiallyExpanded:
            return drawerPartialY(drawerPartialHeight: drawerPartialHeight,
                                  containerViewHeight: containerViewHeight)
        case .fullyExpanded:
            return drawerFullY
        case .collapsed:
            return containerViewHeight
        }
    }

    static func nextStateFrom(currentState: DrawerState,
                              speedY: CGFloat,
                              panGesturePercentage: CGFloat,
                              flickSpeedThreshold: CGFloat,
                              supportsPartialExpansion: Bool) -> DrawerState {
        let isMovingUp = (speedY < 0) // recall that Y-axis points down
        let isMovingDown = (speedY > 0)

        let isMovingQuickly = (abs(speedY) > flickSpeedThreshold)
        let isMovingUpQuickly = isMovingUp && isMovingQuickly
        let isMovingDownQuickly = isMovingDown && isMovingQuickly

        let isHalfTopZone = panGesturePercentage > 0.5

        // === RETURN LOGIC STARTS HERE === //

        if isMovingUpQuickly { return .fullyExpanded }
        if isMovingDownQuickly { return supportsPartialExpansion ? .partiallyExpanded : .collapsed }

        if isHalfTopZone { return .fullyExpanded }

        return supportsPartialExpansion ? .partiallyExpanded : .collapsed
    }
}

// Needs to be a free-floating function because it's accessed by extensions of
// different types.
func equal(_ lhs: CGFloat, _ rhs: CGFloat) -> Bool {
    let epsilon: CGFloat = 0.5
    return abs(lhs - rhs) <= epsilon
}

// Needs to be a free-floating function because it's accessed by extensions of
// different types.
func smallerThanOrEqual(_ lhs: CGFloat, _ rhs: CGFloat) -> Bool {
    return lhs < rhs || equal(lhs, rhs)
}

// Needs to be a free-floating function because it's accessed by extensions of
// different types.
func greaterThanOrEqual(_ lhs: CGFloat, _ rhs: CGFloat) -> Bool {
    return lhs > rhs || equal(lhs, rhs)
}
