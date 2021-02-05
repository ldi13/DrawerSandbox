//
//  DraggableDrawerViewController.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 4/2/21.
//

import UIKit
import SnapKit

final class DraggableDrawerViewController: DrawerViewController {
    var draggableViewController: DraggableDrawerViewControllerType
    var draggableTransitionDelegate: DraggableDrawerTransitionDelegate? {
        return draggableViewController as? DraggableDrawerTransitionDelegate
    }

    var drawerPanGesture: UIPanGestureRecognizer?
    var startingDrawerStateForDrag: DrawerState?
    var targetDrawerState: DrawerState {
        didSet {
            if targetDrawerState == .collapsed {
                shouldDismissAnimated?(false)
            }
            if targetDrawerState != oldValue {
                draggableTransitionDelegate?.drawerStateUpdated(targetDrawerState)
            }
        }
    }
    var hasScrollBeenActivatedDuringCurrentDrag = false
    private let supportsPartialExpansion: Bool

    enum Constants {
        static let flickSpeedThreshold: CGFloat = 0.5
        static let drawerShadowHeight: CGFloat = Grid.default(2)
        static let maxPartialHeightRatio: CGFloat = 0.5
    }

    // MARK: - Initializer

    init(contentViewController: DraggableDrawerViewControllerType, initialState: DrawerState, supportsPartialExpansion: Bool) {
        self.draggableViewController = contentViewController
        self.targetDrawerState = initialState
        self.supportsPartialExpansion = supportsPartialExpansion
        super.init(contentViewController: contentViewController)
        self.dimmingView.alpha = 0
        contentViewController.draggableDrawerDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        draggableTransitionDelegate?.yPositionUpdated(targetDrawerState.isFullyExpanded ? 1 : 0)
        draggableTransitionDelegate?.drawerStateUpdated(targetDrawerState)
    }

    // MARK: - Setup

    override func setupContainer() {
        super.setupContainer()

        refreshConstraint()
        setupHandleView()
        setupDrawerPanRecogniser()
    }

    override func setupDimmingView() {
        super.setupDimmingView()

        dimmingView.alpha = targetDrawerState == .fullyExpanded ? Layout.dimmingViewAlpha : 0.0

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleDimmingViewTap))
        dimmingView.addGestureRecognizer(recognizer)
    }

    private func refreshConstraint() {
        if targetDrawerState == .fullyExpanded {
            drawerTopConstraint?.update(offset: drawerFullY)
        } else if draggableViewController.isDraggable {
            let endingPositionY = GeometryResolver.drawerPositionY(for: targetDrawerState,
                                                                   drawerPartialHeight: drawerPartialHeight,
                                                                   containerViewHeight: containerViewHeight,
                                                                   drawerFullY: drawerFullY)

            drawerTopConstraint?.update(offset: endingPositionY)
        } else {
            drawerTopConstraint?.update(offset: drawerPartialY)
        }
    }

    func setupDrawerPanRecogniser() {
        if let drawerPanGesture = drawerPanGesture {
            containerView.removeGestureRecognizer(drawerPanGesture)
            self.drawerPanGesture = nil
        }

        guard draggableViewController.isDraggable else { return }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        panGesture.delegate = self

        self.drawerPanGesture = panGesture
        containerView.addGestureRecognizer(panGesture)
    }

    func setupHandleView() {
        containerView.handleView.isHidden = !draggableViewController.isDraggable
    }

    @objc dynamic private func handleDimmingViewTap() {
        if supportsPartialExpansion {
            animateTransition(to: .partiallyExpanded)
        }
    }
}

// MARK: - Pan gesture

extension DraggableDrawerViewController: UIGestureRecognizerDelegate {
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startingDrawerStateForDrag = targetDrawerState
            hasScrollBeenActivatedDuringCurrentDrag = false
            fallthrough

        case .changed:
            let speedY = recognizer.velocity(in: view).y / (containerViewHeight - drawerFullY)
            let isMovingUp = (speedY < 0) // recall that Y-axis points down
            let isMovingDown = (speedY >= 0)

            // When the drawer is a its top position and the gesture is going up
            // It means that the user is interacting with the scroll view
            // So we keep the drawer where it is
            if currentDrawerY == drawerFullY && isMovingUp {
                draggableViewController.scrollView.isScrollEnabled = true
                hasScrollBeenActivatedDuringCurrentDrag = true
                recognizer.setTranslation(.zero, in: view)
                return
            } // If the gesture is going down and the user has interacted with the content scroll view, don't to move the drawer
            else if isMovingDown && (draggableViewController.scrollView.isAtTop == false || hasScrollBeenActivatedDuringCurrentDrag) {
                draggableViewController.scrollView.isScrollEnabled = true
                recognizer.setTranslation(.zero, in: view)
                return
            } else {
                hasScrollBeenActivatedDuringCurrentDrag = false
                draggableViewController.scrollView.isScrollEnabled = false
            }

            applyTranslationY(recognizer.translation(in: view).y)
            dimmingView.alpha = panGesturePercentage * Layout.dimmingViewAlpha
            recognizer.setTranslation(.zero, in: view)
            draggableViewController.scrollView.panGestureRecognizer.setTranslation(.zero, in: draggableViewController.scrollView)
            draggableTransitionDelegate?.yPositionUpdated(panGesturePercentage)

        case .ended:
            let drawerSpeedY = recognizer.velocity(in: view).y / (containerViewHeight - drawerFullY)

            // It the scroll view is bouncing or the user has used the content scroll view then the drawer should stay where it started
            if (draggableViewController.scrollView.contentOffset.y < 0 || draggableViewController.scrollView.isScrolling) && currentDrawerY == drawerFullY {
                draggableViewController.scrollView.isScrollEnabled = true

                // Make sure we have the correct alpha on the dimming view before we return
                let expectedAlpha = self.panGesturePercentage * Layout.dimmingViewAlpha
                if expectedAlpha != self.dimmingView.alpha {
                    let animator = makeAnimator()
                    animator.addAnimations { self.dimmingView.alpha = expectedAlpha }
                    animator.startAnimation()
                }

                return
            }

            let endingState = GeometryResolver.nextStateFrom(
                currentState: currentDrawerState,
                speedY: drawerSpeedY,
                panGesturePercentage: panGesturePercentage,
                flickSpeedThreshold: Constants.flickSpeedThreshold,
                supportsPartialExpansion: supportsPartialExpansion
            )

            let percentage: CGFloat = endingState == .fullyExpanded ? 1.0 : 0.0
            let animateAlongside = {
                if let transitionController = self.draggableViewController as? DraggableDrawerTransitionDelegate {
                    transitionController.yPositionUpdated(percentage)
                }
            }

            animateTransition(to: endingState, animateAlongside: animateAlongside)
            draggableViewController.scrollView.isScrollEnabled = true

        case .cancelled:
            if let startingState = startingDrawerStateForDrag {
                startingDrawerStateForDrag = nil
                animateTransition(to: startingState)
            }

            draggableViewController.scrollView.isScrollEnabled = true

        default:
            break
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if targetDrawerState == .partiallyExpanded {
            draggableViewController.scrollView.isScrollEnabled = false
        }

        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Transition

private extension DraggableDrawerViewController {
    func animateTransition(to endingState: DrawerState, animateAlongside: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        let endingPositionY = GeometryResolver.drawerPositionY(for: endingState,
                                                               drawerPartialHeight: drawerPartialHeight,
                                                               containerViewHeight: containerViewHeight,
                                                               drawerFullY: drawerFullY)
        let animator = makeAnimator()

        currentDrawerY = endingPositionY

        animator.addAnimations {
            self.dimmingView.alpha = endingState == .fullyExpanded ? Layout.dimmingViewAlpha : 0
            animateAlongside?()
            self.view.layoutIfNeeded()
        }

        animator.addCompletion { endingPosition in
            if endingPosition != .end {
                self.targetDrawerState = GeometryResolver.drawerState(for: self.currentDrawerY,
                                                                      drawerPartialHeight: self.drawerPartialY,
                                                                      containerViewHeight: self.containerViewHeight,
                                                                      drawerFullY: self.drawerFullY)
            } else {
                self.targetDrawerState = endingState
            }

            completion?()
        }

        animator.startAnimation()
    }

    func applyTranslationY(_ translationY: CGFloat) {
        guard translationY != 0 else { return }

        currentDrawerY += translationY
        targetDrawerState = currentDrawerState
    }

    func makeAnimator() -> UIViewPropertyAnimator {
        let duration = 0.4

        return UIViewPropertyAnimator(duration: duration,
                                      timingParameters: UISpringTimingParameters(dampingRatio: 0.8))
    }
}

extension DraggableDrawerViewController: DraggableDrawerDelegate {
    func update(to state: DrawerState) {
        targetDrawerState = state
        drawerConfigurationUpdated()
    }

    func drawerConfigurationUpdated() {
        containerView.handleView.isHidden = !draggableViewController.isDraggable
        refreshDrawerFullY()

        refreshConstraint()
        setupDrawerPanRecogniser()

        let animator = makeAnimator()
        let percentage: CGFloat = targetDrawerState == .fullyExpanded ? 1.0 : 0.0
        let dimmingViewAlpha: CGFloat = targetDrawerState == .fullyExpanded ? Layout.dimmingViewAlpha : 0.0

        animator.addAnimations {
            self.dimmingView.alpha = dimmingViewAlpha
            self.draggableTransitionDelegate?.yPositionUpdated(percentage)
            self.view.layoutIfNeeded()
        }

        animator.startAnimation()
    }
}
