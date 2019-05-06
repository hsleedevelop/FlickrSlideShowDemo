//
// Created by sergdort on 03/02/2017.
//
// 일부 함수 추가
//
// Copyright (c) 2017 sergdort. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType where E == Bool {
    /// Boolean not operator
    public func not() -> Observable<Bool> {
        return self.map(!)
    }
}

extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}

extension ObservableType {
    
    func catchErrorJustComplete() -> Observable<E> {
        return catchError { _ in
            return Observable.empty()
        }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<E> {
        return asDriver { error in
            return Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}

extension ObservableType {
    func bind<O: ObserverType>(to observer: O, by bag: DisposeBag) -> Self where O.E == E {
        self.bind(to: observer).disposed(by: bag)
        return self
    }
    
    func bind(to relay: RxCocoa.BehaviorRelay<Self.E>, by bag: DisposeBag) -> Self {
        self.bind(to: relay).disposed(by: bag)
        return self
    }
}

extension SharedSequenceConvertibleType where Self.SharingStrategy == RxCocoa.DriverSharingStrategy {
    
    func drive<O: ObserverType>(_ observer: O, by bag: DisposeBag) -> Self where O.E == E {
        self.drive(observer).disposed(by: bag)
        return self
    }
}
