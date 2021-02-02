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
    @Published var lastContact: Date?
    
    var publishRate: Int = 60
    
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
    private var readStart = Date()
    
    
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
        case TemperatureCharacteristicUUID, PressureCharacteristicUUID:
            guard let value = characteristic.value else { return }
            let bytes = [UInt8](value)
            var values: [UInt16] = []

            for i in stride(from: 0, to: bytes.count, by: 2) {
                values.append((UInt16(bytes[i]) << 8 | UInt16(bytes[i+1])))
            }
            
            let start = readStart
            // TODO: update freq to be configured.
            let freq: TimeInterval = 1.0 / 25.0

            var measurements: [TimeSeriesMeasurement] = []
            
            for (i, rawVal) in values.reversed().enumerated() {
                
                var valType: TimeSeriesMeasurement.DataType
                var val: Double
                
                if characteristic.uuid == self.TemperatureCharacteristicUUID {
                    valType = .temperature
                    val = Double(rawVal) / 10.0
                } else if characteristic.uuid == self.PressureCharacteristicUUID {
                    valType = .pressure
                    val = (Double(rawVal) + 80000) / 100
                } else {
                    valType = .none
                    val = Double(rawVal)
                }
                
                let measurement = TimeSeriesMeasurement(
                    value: val,
                    date: start.addingTimeInterval(-(freq*Double(i))),
                    type: valType,
                    event: nil
                )
                measurements.append(measurement)
            }
            
//                print("\(characteristic.uuid == self.TemperatureCharacteristicUUID ? "temp" : "pressure")")
//                print("inserting: \(measurements.count) records")
//
//                let startDate = SQLiteDatabase.dateFormatter.string(from: measurements.max(by: { $0.date > $1.date })!.date)
//                print("startDate: \(startDate) records")
//
//                let endDate = SQLiteDatabase.dateFormatter.string(from: measurements.min(by: { $0.date > $1.date })!.date)
//                print("endDate: \(endDate) records")
//                print()
            try? SQLiteDatabase.main?.executeSQL(sql: measurements.insertSQL())
            
        case IsDataReadyCharacteristicUUID:
            if let value = characteristic.value, let raw = UInt64(value.hexEncodedString(), radix: 16) {
                if raw == 1 {
                    readStart = Date()
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
