//
//  Int+Id.swift
//  FaceBit Companion
//
//  Created by blaine on 1/18/21.
//

import Foundation

class MemoryId {
    private var _id: Int = 1
    
    var next: Int {
        _id += 1
        return _id
    }
    
    var last: Int {
        return _id
    }
}
