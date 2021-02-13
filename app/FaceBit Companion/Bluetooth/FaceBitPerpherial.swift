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
    let mainServiceUUID = CBUUID(string: "6243FABC-23E9-4B79-BD30-1DC57B8005D6")
    private let DataReadyCharacteristicUUID = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8783")
    private let TimeSyncCharacteristicUUID = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8787")
    
    private let DataReadyNoData: Data = Data([UInt8]([8]))

    var name = "SMARTPPE"
    
    @Published var state: PeripheralState = .notFound
    @Published var lastContact: Date?
    
    var publishRate: Int = 60
    
    var peripheral: CBPeripheral? {
        didSet {
            peripheral?.delegate = self
            didUpdateState()
        }
    }
    
    private var currentEvent: SmartPPEEvent?
    
    var readChars: [FaceBitReadCharacteristic]
    
    
    required init(readChars: [FaceBitReadCharacteristic]) {
        self.readChars = readChars
        
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
        
        guard let service = services.first(where: { $0.uuid == mainServiceUUID }) else {
            return
        }
        
        BLELogger.info("Discovered Main Service")
        peripheral
            .discoverCharacteristics(
                readChars.map({ $0.uuid }) + [DataReadyCharacteristicUUID, TimeSyncCharacteristicUUID],
                for: service
            )
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == DataReadyCharacteristicUUID {
                BLELogger.info("Discovered Data Ready Characteristic \(characteristic)")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.uuid == TimeSyncCharacteristicUUID {
                BLELogger.info("Discovered Time Sync Characteristic \(characteristic)")
                updateTimeSync(peripheral: peripheral, characteristic: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value else { return }
        
        switch characteristic.uuid {
        case DataReadyCharacteristicUUID:
            handleReadReady(value)
        case TemperatureCharacteristic.uuid, PressureCharacteristic.uuid:
            updateReadReady(DataReadyNoData, peripheral: peripheral)
            recordTimeSeriesData(value, uuid: characteristic.uuid)
        case RespiratoryRateCharacteristic.uuid, HeartRateCharacteristic.uuid:
            if let c = readChars.first(where: { $0.uuid == characteristic.uuid }) {
                updateReadReady(DataReadyNoData, peripheral: peripheral)
                c.processRead(value)
            }
            
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print()
    }
    
    private func updateTimeSync(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        let timestamp: UInt64 = UInt64(Date().timeIntervalSince1970.rounded())
        let data = Data(timestamp.toBytes)
        
        BLELogger.info("Writting Timestamp: \(timestamp)")
        
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        
    }
    
    private func updateReadReady(_ data: Data, peripheral: CBPeripheral) {
        guard let service = peripheral.services?.first(where: { $0.uuid == mainServiceUUID }) else {
            return
        }
        
        if let readReadyChar = service.characteristics?.first(where: { $0.uuid == DataReadyCharacteristicUUID }) {
            BLELogger.info("Updateing Read Ready: NO_DATA")
            peripheral.writeValue(DataReadyNoData, for: readReadyChar, type: .withoutResponse)
//            peripheral.readValue(for: readReadyChar)
        }
    }
    
    private func handleReadReady(_ data: Data) {
        let readValue = Int([UInt8](data)[0])
        
        if readValue == 8 {
            BLELogger.info("Data Ready: NO_DATA")
            return
        }
        
        if var readChar = readChars.first(where: { $0.readValue == readValue }),
           let characteristics = peripheral?.services?.first(where: { $0.uuid == self.mainServiceUUID })?.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == readChar.uuid {
                    readChar.readStart = Date()
                    BLELogger.info("Read Ready: \(readChar.name) (\(readChar.readStart))")
                    peripheral?.readValue(for: characteristic)
                }
            }
        }
    }
    
    // TODO: move into characteristic data structure
    private func recordTimeSeriesData(_ data: Data, uuid: CBUUID) {
        guard let readChar = readChars.first(where: { $0.uuid == uuid }) else { return }
        
        let bytes = [UInt8](data)
        var values: [UInt16] = []
        
        let millisecondBytes = Array(bytes[0..<8])
        var millisecondOffset: UInt64 = 0
        for byte in millisecondBytes.reversed() {
            millisecondOffset = millisecondOffset << 8
            millisecondOffset = millisecondOffset | UInt64(byte)
        }
        
        let freqBytes = Array(bytes[8..<12])
        var freqRaw: UInt32 = 0
        for byte in freqBytes.reversed() {
            freqRaw = freqRaw << 8
            freqRaw = freqRaw | UInt32(byte)
        }
        let freq: Double = Double(freqRaw) / 100.0
        
        let numSamples = Int(bytes[12])
        
        let payload = Array(bytes[13..<13+(numSamples*2)])

        for i in stride(from: 0, to: payload.count, by: 2) {
            values.append((UInt16(payload[i]) << 8 | UInt16(payload[i+1])))
        }
        
        let start = readChar.readStart.addingTimeInterval(Double(millisecondOffset) / 1000.0)
        let period: Double = 1.0 / Double(freq)
        
        BLELogger.info("""
            Processing \(readChar.name) Data
                - Number of samples: \(numSamples)
                - Offset: \(millisecondOffset)
                - Frequency: \(freq)
        """)
        
        let dataType: TimeSeriesDataRead.DataType
        switch uuid {
        case TemperatureCharacteristic.uuid: dataType = .temperature
        case PressureCharacteristic.uuid: dataType = .pressure
        default: dataType = .none
        }
        
        let dataRead = TimeSeriesDataRead(
            dataType: dataType,
            frequency: freq,
            millisecondOffset: Int(millisecondOffset),
            startTime: start,
            numSamples: numSamples
        )
        
        SQLiteDatabase.main?.insertRecord(record: dataRead) { (dataRead) in
            guard let dataRead = dataRead else { return }
            
            var measurements: [TimeSeriesMeasurement] = []

            for (i, rawVal) in values.reversed().enumerated() {
                var val: Double
                
                if dataType == .temperature {
                    val = Double(rawVal) / 100.0
                } else if dataType == .pressure {
                    val = (Double(rawVal) + 80000) / 100
                } else {
                    val = Double(rawVal)
                }
                
                let measurement = TimeSeriesMeasurement(
                    value: val,
                    date: start.addingTimeInterval(-(period*Double(i))),
                    dataRead: dataRead,
                    event: nil
                )
                measurements.append(measurement)
            }

            PersistanceLogger.info("Inserting \(measurements.count) \(readChar.name) time series records.")
            SQLiteDatabase.main?.executeSQL(sql: measurements.insertSQL())
        }
    }
}
