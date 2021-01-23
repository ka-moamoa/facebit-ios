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
    
    var publishRate: Int = 5
    
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
                
                let temp = Double(raw) / 10000.0
                let measurement = TimeSeriesMeasurement(
                    value: temp,
                    date: Date(),
                    type: .temperature,
                    event: currentEvent
                )
                
                _temperatureReadingsCache.append(measurement)
                try? SQLiteDatabase.main?.insertRecord(record: measurement)
                BLELogger.debug("Temperature Reading: \(self.latestTemperature)")
            }
        case PressureCharacteristicUUID:
            if let value = characteristic.value, let raw = UInt64(value.hexEncodedString(), radix: 16) {
                guard Double(raw) != 0.0 else { return }
                
                let pressure = Double(raw) / 100.0
                let measurement = TimeSeriesMeasurement(
                    value: pressure,
                    date: Date(),
                    type: .pressure,
                    event: currentEvent
                )
                
                _pressureReadingsCache.append(measurement)
                try? SQLiteDatabase.main?.insertRecord(record: measurement)
                BLELogger.debug("Pressure Reading: \(self.latestPressure)")
            }
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
}
