//
//  FacebitReadCharacteristic.swift
//  FaceBit Companion
//
//  Created by blaine on 2/4/21.
//

import Foundation
import CoreBluetooth

/*
 enum data_ready_t
     {
         PRESSURE = 1,
         TEMPERATURE = 2,
         ACCELEROMETER = 3,
         RESPIRATORY_RATE = 4,
         MASK_FIT = 5,
         COUGH_SAMPLE = 6,
         HEART_RATE = 7,
         NO_DATA = 8
     };
 */


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

protocol MetricCharacteristic {
    static var dataType: MetricMeasurement.DataType { get }
}

extension MetricCharacteristic {
    var dataType: MetricMeasurement.DataType { return Self.dataType }
    
    func processMetricRead(_ data: Data) {
        let bytes = [UInt8](data)
        
        let timestampBytes = Array(bytes[0..<8])
        var timestamp: UInt64 = 0
        for byte in timestampBytes.reversed() {
            timestamp = timestamp << 8
            timestamp = timestamp | UInt64(byte)
        }
        
        let value = bytes[8]
        BLELogger.info("value from characteristic \(dataType.rawValue): \(value)")
        
        let measurement = MetricMeasurement(
            value: Double(value),
            dataType: dataType,
            timestamp: timestamp,
            date: Date()
        )
        
        SQLiteDatabase.main?.insertRecord(record: measurement)
    }
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

class RespiratoryRateCharacteristic: FaceBitReadCharacteristic, MetricCharacteristic {
    static let name = "Respiratory Rate"
    static let uuid = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8784")
    static let readValue = 4
    
    static let dataType: MetricMeasurement.DataType = .respiratoryRate
    
    var readStart: Date = Date()
    
    func processRead(_ data: Data) {
        processMetricRead(data)
    }
}

class HeartRateCharacteristic: FaceBitReadCharacteristic, MetricCharacteristic {
    static let name = "Heart Rate"
    static let uuid = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8785")
    static let readValue = 7
    
    static let dataType: MetricMeasurement.DataType = .heartRate
    
    var readStart: Date = Date()
    
    func processRead(_ data: Data) {
        processMetricRead(data)
    }
}

class MaskOnOffCharacteristic: FaceBitReadCharacteristic {
    enum State: Int, CaseIterable, Identifiable {
        case offInactive = 0
        case offActive
        case on
        case uninitialized
        
        var id: Int { return self.rawValue }
    }
    
    static let name = "Mask On/Off"
    static let uuid = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8786")
    static let readValue = 5
    
    static let dataType: MetricMeasurement.DataType = .heartRate
    
    var readStart: Date = Date()
    
    func processRead(_ data: Data) {
        let bytes = [UInt8](data)
        
        let timestampBytes = Array(bytes[0..<8])
        var timestamp: UInt64 = 0
        for byte in timestampBytes.reversed() {
            timestamp = timestamp << 8
            timestamp = timestamp | UInt64(byte)
        }
        
        let value = bytes[8]
        BLELogger.info("value from mask on/off characteristic: \(value), timestamp: \(timestamp)")
        
        let timeRecord = Timestamp(
            dataType: value == 1 ? .maskOff : .maskOn,
            date: Date()
        )
        
        SQLiteDatabase.main?.insertRecord(record: timeRecord)
    }
}
