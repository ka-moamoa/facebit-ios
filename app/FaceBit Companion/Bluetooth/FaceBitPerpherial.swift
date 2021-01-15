//
//  Perpherial.swift
//  FaceBit Companion
//
//  Created by blaine on 1/14/21.
//

import Foundation
import CoreBluetooth
import Combine

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

enum PeripheralState: String {
    case notFound = "not found"
    case connected = "connected"
    case disconnected = "disconnected"
}

protocol Peripheral {
    var name: String { get }
    var mainServiceUUID: CBUUID { get }
    
    var peripheral: CBPeripheral? { get set }
    var state: PeripheralState { get }
    
    func didUpdateState()
}

class FaceBitPeripheral: NSObject, Peripheral, ObservableObject  {
    var mainServiceUUID = CBUUID(string: "6243FABC-23E9-4B79-BD30-1DC57B8005D6")
    var name = "GattServer"
    
    @Published var state: PeripheralState = .notFound
    @Published var latestTemperature: Double = 0.0
    @Published var latestPressure: Double = 0.0
    
    typealias Measurement = (value: Double, timestamp: Date)
    @Published var PressureReadings: [TimeSeriesMeasurement] = []
    @Published var TemperatureReadings: [TimeSeriesMeasurement] = []
    
    var peripheral: CBPeripheral? {
        didSet {
            peripheral?.delegate = self
            didUpdateState()
        }
    }
    
    private let TemperatureCharacteristicUUID = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8782")
    private let PressureCharacteristicUUID = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8781")
    
    required override init() {
        super.init()
    }
    
    func didUpdateState() {
        guard let peripheral = self.peripheral else { state = .notFound; return }
        switch peripheral.state {
        case .connected:
            state = .connected
            print("connected")
            peripheral.discoverServices([mainServiceUUID])
        case .connecting, .disconnected, .disconnecting:
            state = .disconnected
        @unknown default:
            state = .notFound
        }
    }
}

extension FaceBitPeripheral: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics([TemperatureCharacteristicUUID, PressureCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case TemperatureCharacteristicUUID:
            if let value = characteristic.value, let raw = UInt64(value.hexEncodedString(), radix: 16) {
                guard Double(raw) != 0.0 else { return }
                
                print("temp raw \(raw), \(value.hexEncodedString())")
                latestTemperature = Double(raw) / 10000.0
                TemperatureReadings.append(
                    TimeSeriesMeasurement(
                        value: latestTemperature,
                        date: Date()
                    )
                )
                print("Temp: \(latestTemperature)")
            }
        case PressureCharacteristicUUID:
            if let value = characteristic.value, let raw = UInt64(value.hexEncodedString(), radix: 16) {
                guard Double(raw) != 0.0 else { return }
                
                print("pressure raw \(raw)")
                latestPressure = Double(raw) / 100.0
                PressureReadings.append(
                    TimeSeriesMeasurement(
                        value: latestPressure,
                        date: Date()
                    )
                )
                print("Pressure: \(latestPressure)")
            }
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
}
