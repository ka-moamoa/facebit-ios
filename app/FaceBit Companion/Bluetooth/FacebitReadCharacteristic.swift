//
//  FacebitReadCharacteristic.swift
//  FaceBit Companion
//
//  Created by blaine on 2/4/21.
//

import Foundation
import CoreBluetooth


protocol FaceBitReadCharacteristic {
    static var name: String { get }
    static var uuid: CBUUID { get }
    static var readValue: Int { get }
    var readStart: Date { get set }
    
    func processRead(_ data: Data)
}

extension FaceBitReadCharacteristic {
    var name: String { return Self.name }
    var uuid: CBUUID { return Self.uuid }
    var readValue: Int { return Self.readValue }
}

class PressureCharacteristic: FaceBitReadCharacteristic {
    static let name = "Pressure"
    static let uuid = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8781")
    static let readValue = 1
    var readStart: Date = Date()
    
    func processRead(_ data: Data) {
        // TODO:
    }
    
}

class TemperatureCharacteristic: FaceBitReadCharacteristic {
    static let name = "Temperature"
    static let uuid = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8782")
    static let readValue = 2
    var readStart: Date = Date()
    
    func processRead(_ data: Data) {
        // TODO:
    }
    
}
