//
//  SmartPPEEvent.swift
//  FaceBit Companion
//
//  Created by blaine on 1/19/21.
//

import Foundation

enum SmartPPEEvent: String, CaseIterable, Codable, Identifiable {
    case normalBreathing = "normal_breathing"
    case deepBreathing = "deep_breathing"
    case talking = "talking"
    case cough = "cough"
    
    var id: String { self.rawValue }
}
