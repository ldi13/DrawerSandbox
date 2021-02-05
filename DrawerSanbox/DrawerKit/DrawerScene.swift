//
//  DrawerContainer.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//


import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum DrawerSetAnimation {
    case appearOnTop, appearFromBehind
}

final class DrawerScene {
    let containerViewController: UIViewController
    var currentDrawerViewController: DrawerViewControllerType?
    var presentedDrawerViewController: DrawerViewControllerType?

    private var previousAccessibilityElements: [Any]?

    private let drawerViewDidChange: PublishSubject<Void>

    private let drawerViewDidAppearRelay: PublishRelay<Void>
    private var drawerViewDidAppearDisposable: Disposable?

    private let drawerViewBoundsRelay: PublishRelay<CGRect>
    private var drawerViewBoundsDisposable: Disposable?

    let drawerViewBoundsObservable: Observable<CGRect>

    var shouldObserveDrawerViewBounds: Bool

    // MARK: - Initializer

    init(containerViewController: UIViewController, shouldObserveDrawerViewBounds: Bool = false) {
        self.shouldObserveDrawerViewBounds = shouldObserveDrawerViewBounds
        self.containerViewController = containerViewController

        self.drawerViewBoundsRelay = PublishRelay<CGRect>()
        let drawerViewBoundsObservable = drawerViewBoundsRelay.asObservable()

        self.drawerViewDidAppearRelay = PublishRelay<Void>()
        let drawerViewDidAppearObservable = drawerViewDidAppearRelay.asObservable()

        self.drawerViewDidChange = PublishSubject<Void>()

        self.drawerViewBoundsObservable = drawerViewDidChange
            .flatMapLatest { Observable.combineLatest(drawerViewBoundsObservable, drawerViewDidAppearObservable) }
            .map { (bounds, _) in bounds }

        debugPrint("INIT - DrawerContainer")
    }

    deinit {
        drawerViewBoundsDisposable?.dispose()
        drawerViewDidAppearDisposable?.dispose()
        
        debugPrint("INIT - DrawerContainer")
    }

    private func updateDrawerViewHeightBinding(with drawerViewController: DrawerViewControllerType) {
        // Drawer View bounds bindings should be updated only when there is a subcription.
        // Please subscribe before calling the `set` function of the DrawerContainer if you have set shouldObserveDrawerViewBounds to true.
        if !shouldObserveDrawerViewBounds {
            return
        }

        if drawerViewDidChange.hasObservers == false {
            fatalError("Drawer View bounds bindings should be updated only when there is a subcription. Please subscribe before calling the `set` function of the DrawerContainer if you have set shouldObserveDrawerViewBounds to true")
        }

        drawerViewDidChange.onNext(())

        drawerViewBoundsDisposable?.dispose()
        drawerViewBoundsDisposable = nil
        drawerViewBoundsDisposable = drawerViewController.drawerContainerView.rx.observe(CGRect.self, "bounds")
            .unwrap()
            .bind(to: drawerViewBoundsRelay)

        drawerViewDidAppearDisposable?.dispose()
        drawerViewDidAppearDisposable = nil
        drawerViewDidAppearDisposable = drawerViewController
            .contentViewController.rx.viewDidAppear
            .asObservable()
            .mapToVoid()
            .bind(to: drawerViewDidAppearRelay)
    }

    // MARK: - Transition

    func set(_ drawerViewController: DrawerViewControllerType, animation: DrawerSetAnimation = .appearOnTop, completion: (() -> Void)? = nil) {
        updateDrawerViewHeightBinding(with: drawerViewController)
        let previousDrawerViewController = self.currentDrawerViewController
        self.currentDrawerViewController = drawerViewController

        // Hide current drawer
        if let previousDrawerViewController = previousDrawerViewController {
            previousDrawerViewController.view.endEditing(true)
            previousDrawerViewController.drawerContainerView.snp.remakeConstraints {
                $0.top.equalTo(previousDrawerViewController.view.snp.bottom).priority(.required)
                $0.leading.trailing.equalToSuperview()
            }
        }

        // Add new drawer
        containerViewController.addChildController(drawerViewController)
        drawerViewController.view.layoutIfNeeded()

        let drawerContainerTopConstraintValue = drawerViewController.drawerContainerView.frame.origin.y
        let drawerContainerHeight = drawerViewController.drawerContainerView.frame.height

        // Put the new drawer outside the screen bounds (the drawer should appear from the bottom of the screen)
        drawerViewController.drawerContainerView.snp.remakeConstraints {
            $0.top.equalTo(drawerViewController.view.snp.bottom).priority(.required)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(drawerContainerHeight)
        }

        if .appearFromBehind == animation, let previousDrawerViewController = previousDrawerViewController {
            containerViewController.view.bringSubviewToFront(previousDrawerViewController.view)
        }

        drawerViewController.view.layoutIfNeeded()

        // Animate the two drawers to their final positions
        drawerViewController.setupContainerLayout()
        drawerViewController.drawerTopConstraint?.update(offset: drawerContainerTopConstraintValue)

        if let presentedDrawerViewController = presentedDrawerViewController {
            // Presented view should always be in front
            containerViewController.view.bringSubviewToFront(presentedDrawerViewController.view)

            // Dismiss presented view
            presentedDrawerViewController.view.endEditing(true)
            presentedDrawerViewController.drawerContainerView.snp.remakeConstraints {
                $0.top.equalTo(presentedDrawerViewController.view.snp.bottom).priority(.required)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(presentedDrawerViewController.drawerContainerView.frame.height)
            }
        }

        UIView.animate(withDuration: Animation.Duration.short, delay: 0.0, options: [.curveEaseIn], animations: {
            previousDrawerViewController?.view.layoutIfNeeded()
            previousDrawerViewController?.dimmingView.alpha = 0
            self.presentedDrawerViewController?.view.layoutIfNeeded()
            self.presentedDrawerViewController?.dimmingView.alpha = 0
        }, completion: { _ in
            self.deinitPresentedViewController()

            if let previousDrawerViewController = previousDrawerViewController {
                self.containerViewController.removeChildController(previousDrawerViewController)
            }
        })

        UIView.animate(withDuration: Animation.Duration.short, delay: 0.0, options: [.curveEaseOut], animations: {
            drawerViewController.view.layoutIfNeeded()
        }, completion: { isFinished in
            if isFinished {
                completion?()
                drawerViewControllerDidAppear(drawerViewController: drawerViewController, isAnimationFinished: isFinished)
            }
        })
    }

    func present(_ drawerViewController: DrawerViewControllerType) {
        presentedDrawerViewController = drawerViewController

        containerViewController.addChildController(drawerViewController)
        drawerViewController.view.layoutIfNeeded()
        // Put the new drawer outside the screen bounds (the drawer should appear from the bottom of the screen)
        let drawerContainerTopConstraintValue = drawerViewController.drawerContainerView.frame.origin.y
        let drawerContainerHeight = drawerViewController.drawerContainerView.frame.height

        drawerViewController.drawerContainerView.snp.remakeConstraints {
            $0.top.equalTo(drawerViewController.view.snp.bottom).priority(.required)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(drawerContainerHeight)
        }

        drawerViewController.view.layoutIfNeeded()

        // Animate the two drawers to their final positions
        drawerViewController.setupContainerLayout()
        drawerViewController.drawerTopConstraint?.update(offset: drawerContainerTopConstraintValue)

        UIView.animate(withDuration: Animation.Duration.short, delay: 0.0, options: [.curveEaseOut], animations: {
            drawerViewController.view.layoutIfNeeded()
        }, completion: { isAnimationFinished in
            drawerViewControllerDidAppear(drawerViewController: drawerViewController, isAnimationFinished: isAnimationFinished)
        })

        drawerViewController.shouldDismissAnimated = { [unowned self] animated in
            self.dismissPresented(animated)
        }
    }

    func dismissPresented(_ animated: Bool) {
        presentedDrawerViewController?.view.endEditing(true)

        self.resetAccessibilityFocus()

        guard animated else {
            deinitPresentedViewController()
            return
        }

        guard let presentedDrawerViewController = presentedDrawerViewController else {
            return
        }

        presentedDrawerViewController.drawerContainerView.snp.remakeConstraints {
            $0.top.equalTo(presentedDrawerViewController.view.snp.bottom).priority(.required)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(presentedDrawerViewController.drawerContainerView.frame.height)
        }

        UIView.animate(withDuration: Animation.Duration.short, delay: 0.0, options: [.curveEaseIn], animations: {
            presentedDrawerViewController.view.layoutIfNeeded()
            presentedDrawerViewController.dimmingView.alpha = 0
        }, completion: { [unowned self] isAnimationFinished in
            drawerViewControllerDidAppear(drawerViewController: self.currentDrawerViewController, isAnimationFinished: isAnimationFinished)
            self.deinitPresentedViewController()
        })
    }

    private func deinitPresentedViewController() {
        if let presentedDrawerViewController = presentedDrawerViewController {
            containerViewController.removeChildController(presentedDrawerViewController)
        }
        presentedDrawerViewController = nil
    }

    func hide(completion: ((Bool) -> Void)? = nil) {
        guard let currentDrawerViewController = currentDrawerViewController else { return }

        currentDrawerViewController.drawerContainerView.snp.remakeConstraints {
            $0.top.equalTo(currentDrawerViewController.view.snp.bottom).priority(.required)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(currentDrawerViewController.drawerContainerView.frame.height)
        }

        UIView.animate(withDuration: Animation.Duration.short, delay: 0.0, options: [.curveEaseIn], animations: {
            currentDrawerViewController.view.layoutIfNeeded()
            currentDrawerViewController.dimmingView.alpha = 0
        }, completion: completion)
    }

    func show() {
        guard let currentDrawerViewController = currentDrawerViewController else { return }

        containerViewController.addChildController(currentDrawerViewController)
        currentDrawerViewController.view.layoutIfNeeded()

        currentDrawerViewController.drawerContainerView.snp.remakeConstraints {
            $0.top.equalTo(currentDrawerViewController.view.snp.bottom).priority(.required)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(currentDrawerViewController.drawerContainerView.frame.height)
        }

        currentDrawerViewController.view.layoutIfNeeded()

        // Put the new drawer outside the screen bounds (the drawer should appear from the bottom of the screen)
        let drawerContainerTopConstraintValue = currentDrawerViewController.drawerContainerView.frame.origin.y
        let drawerContainerHeight = currentDrawerViewController.drawerContainerView.frame.height

        currentDrawerViewController.drawerContainerView.snp.remakeConstraints {
            $0.top.equalTo(currentDrawerViewController.view.snp.bottom).priority(.required)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(drawerContainerHeight)
        }

        currentDrawerViewController.view.layoutIfNeeded()
        currentDrawerViewController.setupContainerLayout()
        currentDrawerViewController.drawerTopConstraint?.update(offset: drawerContainerTopConstraintValue)

        UIView.animate(withDuration: Animation.Duration.short, delay: 0.0, options: [.curveEaseOut], animations: {
            currentDrawerViewController.view.layoutIfNeeded()
        }, completion: nil)
    }

    func removeChildViewControllers() {
        [currentDrawerViewController, presentedDrawerViewController]
            .compactMap { $0 }
            .forEach { [unowned self] (viewController) in
                self.containerViewController.removeChildController(viewController)
            }

        currentDrawerViewController = nil
        presentedDrawerViewController = nil
    }

    func makeAccessibilityFocusOnModalView(_ view: UIView? = nil) {
        self.previousAccessibilityElements = self.containerViewController.view.accessibilityElements
        if let currentView = currentDrawerViewController?.view {
            let viewToAdd = view ?? currentView
            self.containerViewController.view.accessibilityElements = [viewToAdd]
        }
    }

    func resetAccessibilityFocus() {
        if previousAccessibilityElements != nil {
            self.containerViewController.view.accessibilityElements = previousAccessibilityElements
        }
        previousAccessibilityElements = nil
    }
}

// when the drawer finished to appear, tell the content view controller that is also appeared
private func drawerViewControllerDidAppear(drawerViewController: DrawerViewControllerType?, isAnimationFinished: Bool) {
    guard isAnimationFinished else { return }

    if let draggableDrawerType = drawerViewController?.contentViewController as? DraggableDrawerType {
        draggableDrawerType.draggableDrawerDidAppear()
    } else {
        // This will be called if a drawerViewController use the new drawer
        drawerViewController?.drawerDidAppear()
    }
}
