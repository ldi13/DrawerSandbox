//
//  TransactionStatusViewController.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 4/2/21.
//

import UIKit
import SnapKit

final class TransactionStatusViewController: UIViewController {
    
    // MARK: - Initializer
    
    let imageView: UIImageView
    
    init() {
        self.imageView = UIImageView()
        
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

// MARK: - Setup methods

private extension TransactionStatusViewController {
    func setup() {
        [imageView].forEach(view.addSubview)
        setupImageView()
    }
    
    func setupImageView() {
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        imageView.image = UIImage(named: "wallapop_connection")
    }
}
