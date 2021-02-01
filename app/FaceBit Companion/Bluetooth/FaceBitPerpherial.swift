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
    @Published var lastContact: Date?
    
    var publishRate: Int = 60
    
    typealias Measurement = (value: Double, timestamp: Date)
    @Published var PressureReadings: [TimeSeriesMeasurement] = []
    @Published var TemperatureReadings: [TimeSeriesMeasurement] = []
    
    private var _pressureReadingsCache: [TimeSeriesMeasurement] = [] {
        didSet {
            if _pressureReadingsCache.count == publishRate {
                PressureReadings += _pressureReadingsCache
                latestPressure = PressureReadings.last?.value ?? 0.0
                _pressureReadingsCache = []
            }
        }
    }
    
    private var _temperatureReadingsCache: [TimeSeriesMeasurement] = [] {
        didSet {
            if _temperatureReadingsCache.count == publishRate {
                TemperatureReadings += _temperatureReadingsCache
                latestTemperature = TemperatureReadings.last?.value ?? 0.0
                _temperatureReadingsCache = []
            }
        }
    }
    
    var peripheral: CBPeripheral? {
        didSet {
            peripheral?.delegate = self
            didUpdateState()
        }
    }
    
    private let TemperatureCharacteristicUUID = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8782")
    private let PressureCharacteristicUUID = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8781")
    private let IsDataReadyCharacteristicUUID = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8783")
    
    private var currentEvent: SmartPPEEvent?
    
    required override init() {
        super.init()
    }
    
    func didUpdateState() {
        guard let peripheral = self.peripheral else { state = .notFound; return }
        switch peripheral.state {
        case .connected:
            state = .connected
            lastContact = Date()
            BLELogger.info("Connected")
            peripheral.discoverServices([mainServiceUUID])
        case .connecting, .disconnected, .disconnecting:
            state = .disconnected
        @unknown default:
            state = .notFound
        }
    }
    
    func setEvent(_ event: SmartPPEEvent?=nil) {
        self.currentEvent = event
    }
}

extension FaceBitPeripheral: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics([TemperatureCharacteristicUUID, PressureCharacteristicUUID, IsDataReadyCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
//            if characteristic.properties.contains(.read) {
//                peripheral.readValue(for: characteristic)
//            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case TemperatureCharacteristicUUID:
            guard let value = characteristic.value else { return }
            let bytes = [UInt8](value)
            var tempReads: [UInt16] = []

            for i in stride(from: 0, to: bytes.count, by: 2) {
                tempReads.append((UInt16(bytes[i]) << 8 | UInt16(bytes[i+1])))
            }
            
            let start = Date()
            let freq: TimeInterval = 1.0 / 25.0

            for (i, val) in tempReads.reversed().enumerated() {
                let temp = Double(val) / 10.0
                let measurement = TimeSeriesMeasurement(
                    value: temp,
                    date: start.addingTimeInterval(-(freq*Double(i))),
                    type: .temperature,
                    event: currentEvent
                )
                try? SQLiteDatabase.main?.insertRecord(record: measurement)
            }
        case PressureCharacteristicUUID:
            guard let value = characteristic.value else { return }
            let bytes = [UInt8](value)
            var pressureReads: [UInt16] = []

            for i in stride(from: 0, to: bytes.count, by: 2) {
                pressureReads.append((UInt16(bytes[i]) << 8 | UInt16(bytes[i+1])))
            }
            
            let start = Date()
            let freq: TimeInterval = 1.0 / 25.0

            for (i, val) in pressureReads.reversed().enumerated() {
                let pressure = (Double(val) + 80000) / 100
                let measurement = TimeSeriesMeasurement(
                    value: pressure,
                    date: start.addingTimeInterval(-(freq*Double(i))),
                    type: .pressure,
                    event: currentEvent
                )
                try? SQLiteDatabase.main?.insertRecord(record: measurement)
            }

            
        case IsDataReadyCharacteristicUUID:
            if let value = characteristic.value, let raw = UInt64(value.hexEncodedString(), radix: 16) {
                BLELogger.debug("Is Ready \(raw)")
                if raw == 1 {
                    // todo: read temp and pressure
                    if let characteristics = peripheral.services?.first(where: { $0.uuid == self.mainServiceUUID })?.characteristics {
                        for characteristic in characteristics {
                            if characteristic.properties.contains(.read) {
                                peripheral.readValue(for: characteristic)
                            }
                        }
                    }
                }
            }
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
}
