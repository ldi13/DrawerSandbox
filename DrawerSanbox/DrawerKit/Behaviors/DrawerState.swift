//
//  DrawerState.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//

import Foundation

enum DrawerState {
    case partiallyExpanded
    case fullyExpanded
    case collapsed

    var isFullyExpanded: Bool {
        guard case .fullyExpanded = self else { return false }
        return true
    }
}
