//
//  TimerPublisher.swift
//  FaceBit Companion
//
//  Created by blaine on 2/11/21.
//

import Foundation

protocol TimerPublisher {
    var timer: Timer? { get set }
    var timerInterval: TimeInterval { get }
    
    func onFire(_ timer: Timer)
    func start()
    func stop()
}
