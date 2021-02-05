//
//  DrawerHeaderView.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//

import UIKit
import SnapKit

final class DrawerHeaderView: UIView {
    let stackView: UIStackView
    let titleLabel: UILabel
    let closeButton: UIButton

    struct Configuration {
        let title: String?
        let showCloseButton: Bool

        init(title: String?, showCloseButton: Bool = false) {
            self.title = title
            self.showCloseButton = showCloseButton
        }
    }

    // MARK: - Initializers

    init() {
        self.stackView = UIStackView()
        self.titleLabel = UILabel()
        self.closeButton = UIButton(type: .custom)

        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        addSubview(stackView)
        [titleLabel, closeButton].forEach(stackView.addArrangedSubview)

        self.accessibilityElements = [titleLabel]

        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(Layout.View.innerPadding)
            $0.trailing.equalTo(-Layout.View.innerPadding)
        }
        backgroundColor = .white

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16

        setupTitleLabel()
        setupCloseButton()
    }

    private func setupTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 21, weight: .regular)
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true

        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func setupCloseButton() {
        closeButton.setImage(UIImage(named: "ic-close-drawer"), for: .normal)
        closeButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 24, height: 24))
        }
    }

    // MARK: - Public

    func updateConfiguration(_ configuration: Configuration?) {
        titleLabel.text = configuration?.title
        closeButton.isHidden = !(configuration?.showCloseButton ?? false)
    }
}
