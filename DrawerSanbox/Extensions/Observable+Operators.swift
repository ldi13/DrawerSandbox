//
//  Observable+Operators.swift
//  DrawerSandbox
//
//  Created by Lorenzo Di Vita on 3/2/21.
//

import UIKit
import RxSwift
import RxCocoa

extension Observable {
    func mapToVoid() -> Observable<Void> {
        return map { _ in () }
    }

    func dispatchOn(_ queue: DispatchQoS) -> Observable<Element> {
        return observe(on: SerialDispatchQueueScheduler(qos: queue))
    }

    func dispatchOnMainScheduler() -> Observable<Element> {
        return observe(on: MainScheduler.instance)
    }

    func block(_ applicationState: UIApplication.State) -> Observable<Element> {
        if UIApplication.shared.applicationState == applicationState {
            return .empty()
        }

        return self
    }
}
