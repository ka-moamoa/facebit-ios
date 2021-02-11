//
//  DatabasePublisher.swift
//  FaceBit Companion
//
//  Created by blaine on 2/2/21.
//

import Foundation


protocol DatabasePublisher {
    associatedtype T
    
    var query: String { get }
    var items: [T] { get }
}
