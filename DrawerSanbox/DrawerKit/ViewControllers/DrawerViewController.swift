//
//  DrawerViewController.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 4/2/21.
//

import UIKit
import SnapKit

class DrawerViewController: UIViewController, DrawerViewControllerType {
    public var drawerContainerView: UIView {
        return containerView
    }

    let passThroughView: PassThroughView
    let dimmingView: UIView
    let containerView: DrawerView
    var contentViewController: UIViewController

    var drawerFullY: CGFloat
    let topMargin: CGFloat

    var drawerTopConstraint: Constraint?

    var shouldDismissAnimated: ((Bool) -> Void)?

    // MARK: - Initializer

    init(contentViewController: UIViewController) {
        self.dimmingView = UIView()
        self.containerView = DrawerView()
        self.passThroughView = PassThroughView(frame: UIScreen.main.bounds)
        self.contentViewController = contentViewController

        let topLayoutGuideLength = UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets.top ?? 0
        self.topMargin = max(topLayoutGuideLength, 20)

        drawerFullY = topMargin

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override func loadView() {
        view = passThroughView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        [dimmingView, containerView]
            .forEach(view.addSubview)

        setupContainer()
        setupDimmingView()
    }

    // MARK: - Setup

    func setupContainer() {
        addChild(contentViewController)
        containerView.setContent(contentViewController.view)
        contentViewController.didMove(toParent: self)

        setupContainerLayout()
    }

    func setupContainerLayout() {
        containerView.snp.remakeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            drawerTopConstraint = $0.top.equalTo(drawerFullY).constraint
        }
    }

    func setupDimmingView() {
        dimmingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        dimmingView.backgroundColor = .black
        dimmingView.alpha = 0
    }

    func refreshDrawerFullY() {
        drawerFullY = topMargin
    }

    func drawerDidAppear() {
        UIAccessibility.post(notification: .screenChanged, argument: containerView.headerView.titleLabel)
    }
}
