//
//  AppCoordinator.swift
//  DrawerSanbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//


import UIKit
import RxSwift

public protocol CoordinatorType: class {
    var childCoordinators: [CoordinatorType] { get set }
    func start()
    func removeCoordinator(_ coordinator: CoordinatorType)
}

public extension CoordinatorType {
    func removeCoordinator(_ coordinator: CoordinatorType) {
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }
    }

    var debugDescription: String {
        let description = childCoordinators.reduce("\n") { (acc, coordinator) -> String in
            return acc + " -- " + coordinator.debugDescription
        }

        return String(describing: type(of: self)).components(separatedBy: ".").last ?? "" + description
    }
}

final class AppCoordinator: CoordinatorType {
    private let window: UIWindow
    private var drawerScene: DrawerScene?
    private let disposeBag: DisposeBag
    
    var childCoordinators: [CoordinatorType]
    
    // MARK: - Initializer

    init(window: UIWindow) {
        self.childCoordinators = []
        self.window = window
        self.disposeBag = DisposeBag()

       debugPrint("INIT - app coordinator")
    }

    deinit {
        debugPrint("DEINIT - app coordinator")
    }
    
    // MARK: - CoordinatorType methods
    
    func start() {
        let transactionStatusViewController = TransactionStatusViewController()
        setDrawerScene(with: transactionStatusViewController)
        
        window.rootViewController = transactionStatusViewController
        window.makeKeyAndVisible()
    }
}

// MARK:- DrawerScene methods

private extension AppCoordinator {
    func setDrawerScene(with rootViewController: UIViewController) {
        let drawerScene = DrawerScene(
            containerViewController: rootViewController,
            shouldObserveDrawerViewBounds: true
        )
        
        drawerScene
            .drawerViewBoundsObservable
            .dispatchOnMainScheduler()
            .subscribe()
            .disposed(by: disposeBag)
        
        let draggableDrawerViewController = createDraggableDrawerViewController()
        drawerScene.set(draggableDrawerViewController)
        
        self.drawerScene = drawerScene
    }
    
    func createDraggableDrawerViewController() -> DrawerViewControllerType {
        let transactionDetailsViewController = TransactionDetailsViewController()
        let drawerContentViewController = DrawerContentViewController(contentViewController: transactionDetailsViewController)
        let draggableDrawerViewController = DraggableDrawerViewController(
            contentViewController: drawerContentViewController,
            initialState: .partiallyExpanded,
            supportsPartialExpansion: true
        )
        
        return draggableDrawerViewController
    }
}
