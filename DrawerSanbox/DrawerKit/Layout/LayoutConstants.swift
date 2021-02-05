//
//  LayoutConstants.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//

import UIKit

enum Animation {
    enum Duration {
        static let short: Double = 0.2
    }
}



extension UIColor {
    static let night200 = UIColor(red: 0.875, green: 0.894, blue: 0.918, alpha: 1)
}

enum Grid {
    static func `default`(_ n: Int) -> CGFloat {
        return CGFloat(n) * 4.0
    }
}

enum Layout {
    enum Button {
        static let primaryHeight: CGFloat = 56
    }

    enum View {
        static let innerPadding: CGFloat = Grid.default(5)
    }
    
    static let dimmingViewAlpha: CGFloat = 0.5
}
