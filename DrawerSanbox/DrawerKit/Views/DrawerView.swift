//
//  DrawerView.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//

import UIKit
import SnapKit

final class DrawerView: UIView {
    let topBorderView: UIImageView
    let headerView: DrawerHeaderView
    let handleView: UIView
    var contentView: UIView?

    private var headerViewHeightZeroConstraint: Constraint?

    // MARK: - Initializer

    init() {
        self.topBorderView = UIImageView(image: UIImage(named: "img-drawer-borders"))
        self.headerView = DrawerHeaderView()
        self.handleView = UIView()

        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        isAccessibilityElement = false
        accessibilityElements = [headerView, handleView]

        [topBorderView, handleView, headerView].forEach(addSubview)

        setupTopBorderView()
        setupHandleView()
        setupHeaderView()
    }

    private func setupTopBorderView() {
        topBorderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(28)
        }
    }

    private func setupHandleView() {
        handleView.backgroundColor = .night200
        handleView.layer.masksToBounds = true
        handleView.layer.cornerRadius = 3
        handleView.isHidden = true

        handleView.snp.makeConstraints {
            $0.top.equalTo(13.5)
            $0.height.equalTo(5)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(36)
        }
    }

    private func setupHeaderView() {
        headerView.snp.makeConstraints {
            $0.top.equalTo(topBorderView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            headerViewHeightZeroConstraint = $0.height.equalTo(0).priority(.required).constraint
        }
    }

    // MARK: - Public

    func setContent(_ view: UIView) {
        contentView = view
        addSubview(view)
        accessibilityElements?.append(view)

        view.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    func updateHeaderConfiguration(_ configuration: DrawerHeaderView.Configuration?) {
        if configuration == nil {
            headerViewHeightZeroConstraint?.activate()
        } else {
            headerViewHeightZeroConstraint?.deactivate()
        }

        headerView.updateConfiguration(configuration)
        setNeedsLayout()
        layoutIfNeeded()
    }
}
