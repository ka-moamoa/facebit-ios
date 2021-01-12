//
//  BluetoothConnectionManager.swift
//  FaceBit Companion
//
//  Created by blaine on 1/12/21.
//

import Foundation
import CoreBluetooth
import Combine

class BluetoothConnectionManager: NSObject, CBCentralManagerDelegate, ObservableObject {
    var centralManager: CBCentralManager!
    
    @Published var stateString = "uninitialized"
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central state unknown")
            stateString = "unknown"
        case .resetting:
            print("central state restting")
            stateString = "resetting"
        case .unsupported:
            print("central state is unsupported")
            stateString = "unsupported"
        case .unauthorized:
            print("central state unauthorized")
            stateString = "unauthorized"
        case .poweredOff:
            print("central state powered off")
            stateString = "powered off"
        case .poweredOn:
            print("central state powered on")
            stateString = "powered on"
        @unknown default:
            fatalError("unhandled centeral state")
        }
    }
    
}
