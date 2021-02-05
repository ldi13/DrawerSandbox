//
//  TransactionDetailsViewController.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 4/2/21.
//

import UIKit

final class TransactionDetailsViewController: UIViewController {
    // MARK: - Properties
    
    let scrollView: UIScrollView
    var isDraggable = true
    weak var draggableDrawerDelegate: DraggableDrawerDelegate?
    
    // MARK: - Initializer
    
    init() {
        self.scrollView = UIScrollView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 51/255, green: 212/255, blue: 188/255, alpha: 1)
    }
}

// MARK: - DraggableDrawerType

extension TransactionDetailsViewController: DraggableDrawerType {
    var heightOfPartiallyExpandedDrawer: CGFloat {
        return 50
    }

    var isClosable: Bool {
        return false
    }
}
