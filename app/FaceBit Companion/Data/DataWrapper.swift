//
//  DataWrapper.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import Foundation


class DataWrapper<T: Codable>: Codable {
    let data: T
    
    init(data: T) {
        self.data = data
    }
}
