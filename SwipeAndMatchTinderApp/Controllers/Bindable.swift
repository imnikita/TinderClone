//
//  Bindable.swift
//  SwipeAndMatchTinderApp
//
//  Created by user on 29.08.2021.
//

import Foundation


class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?) -> Void)?
    
    func bind(observer: @escaping (T?) -> Void) {
        self.observer = observer
    }
}
