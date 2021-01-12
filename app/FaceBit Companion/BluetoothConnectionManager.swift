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
    
    @Published var centralStateString = "uninitialized"
    @Published var peripheralStateString = "device disconnected"
    
    private var peripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central state unknown")
            centralStateString = "unknown"
        case .resetting:
            print("central state restting")
            centralStateString = "resetting"
        case .unsupported:
            print("central state is unsupported")
            centralStateString = "unsupported"
        case .unauthorized:
            print("central state unauthorized")
            centralStateString = "unauthorized"
        case .poweredOff:
            print("central state powered off")
            centralStateString = "powered off"
        case .poweredOn:
            print("central state powered on")
            centralStateString = "powered on"
            startScan()
        @unknown default:
            fatalError("unhandled centeral state")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "blainepi" {
            print(peripheral)
            peripheralStateString = "device connected"
            self.peripheral = peripheral
            stopScan()
            connect()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected: \(peripheral)")
        self.peripheral?.delegate = self
        self.peripheral?.discoverServices(nil)
    }
    
    private func startScan() {
        peripheralStateString = "scanning"
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    private func stopScan() {
        centralManager.stopScan()
    }
    
    private func connect() {
        guard let peripheral = self.peripheral else { return }
        centralManager.connect(peripheral)
    }
    
}

extension BluetoothConnectionManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic.value ?? "no value")
    }
}
