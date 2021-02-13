//
//  BluetoothConnectionManager.swift
//  FaceBit Companion
//
//  Created by blaine on 1/12/21.
//

import Foundation
import CoreBluetooth
import Combine
import UIKit

class BluetoothConnectionManager: NSObject, ObservableObject {
    static let shared = BluetoothConnectionManager()
    
    var centralManager: CBCentralManager!
    
    @Published var centralState: CBManagerState = .unknown
    @Published var isScanning: Bool = false
        
    private var scanOnPoweredOn: Bool = true
    private var peripherals: [Peripheral] = []
    
    required override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func searchFor(peripheral: Peripheral) {
        if !peripherals.contains(where: { $0.name == peripheral.name }) {
            peripherals.append(peripheral)
        }
        
        guard centralManager.state == .poweredOn else { return }
        
        if isScanning { stopScan() }
        startScan()
    }
    
    private func startScan() {
        print("start scan")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        isScanning = centralManager.isScanning
    }
    
    func stopScan() {
        centralManager.stopScan()
        isScanning = centralManager.isScanning
    }
    
    func disconnect(_ peripheral: Peripheral) {
        guard let p = peripheral.peripheral else { return }
        
        centralManager.cancelPeripheralConnection(p)
    }
    
    private func connect(_ peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: [:])
    }
}

extension BluetoothConnectionManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.centralState = central.state
        
        switch central.state {
        case .poweredOn:
            print("powered on")
            if scanOnPoweredOn { startScan() }
        default: break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard var peri = peripherals.first(where: { $0.name == peripheral.name }) else { return }
        BLELogger.info("found peripheral: \(peri.name)")
        peri.peripheral = peripheral
        centralManager.connect(
            peripheral,
            options: nil
        )
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let peri = peripherals.first(where: { $0.name == peripheral.name }) else { return }
        BLELogger.info("connceted to: \(peri.name)")
        peri.didUpdateState()
        stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let peri = peripherals.first(where: { $0.name == peripheral.name }) else { return }
        BLELogger.info("\(peri.name) disconnected")
        peri.didUpdateState()
    }
}

//extension BluetoothConnectionManager: CBPeripheralDelegate {
//    
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard let characteristics = service.characteristics else { return }
//        peripheral.state
//        
//        for characteristic in characteristics {
//            print(characteristic)
//            if characteristic.properties.contains(.read) {
//                peripheral.readValue(for: characteristic)
//            }
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
//        let currentTime = CACurrentMediaTime()
//        print("\(currentTime) \(RSSI)")
//        peripheral.readRSSI()
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print(characteristic.value ?? "no value")
//    }
//}
