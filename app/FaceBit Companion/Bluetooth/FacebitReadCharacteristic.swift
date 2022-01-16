//
//  FacebitReadCharacteristic.swift
//  FaceBit Companion
//
//  Created by blaine on 2/4/21.
//
//  @copyright Copyright (c) 2022 Ka Moamoa
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 of the license.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

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

extension MetricCharacteristic where Self:FaceBitReadCharacteristic {
    var dataType: MetricMeasurement.DataType { return Self.dataType }
    
    func processMetricRead(_ data: Data) {
        let bytes = [UInt8](data)
        
        let timestampBytes = Array(bytes[0..<8])
        var timestamp: UInt64 = 0
        for byte in timestampBytes.reversed() {
            timestamp = timestamp << 8
            timestamp = timestamp | UInt64(byte)
        }
        
        let valueBytes = Array(bytes[8..<10])
        var valueInt16: UInt16 = 0
        for byte in valueBytes.reversed() {
            valueInt16 = valueInt16 << 8
            valueInt16 = valueInt16 | UInt16(byte)
        }
        
//        if self.dataType == .respiratoryRate {
//            if value == 255 { // failure indication
//                value = -1.0
//            } else {
//                value = value / 10.0
//            }
//        }
        
        let value: Double = Double(valueInt16)
//        switch self.dataType {
//            case .respiratoryRate: value = Double(valueInt16) / 10.0
//            default: value = Double(valueInt16)
//        }
        
        BLELogger.info("value from characteristic \(dataType.rawValue): \(value)")
            
        
        var measurement = MetricMeasurement(
            value: value,
            dataType: dataType,
            timestamp: Int64(timestamp),
            date: Date(),
            eventId: nil
        )
        
        do {
            try measurement.save()
        } catch {
            PersistanceLogger.error("Cannot insert \(self.name): \(error.localizedDescription)")
        }
    }
}

protocol TimeSeriesCharacteristic {
    static var dataType: TimeSeriesDataRead.DataType { get }
}

extension TimeSeriesCharacteristic where Self:FaceBitReadCharacteristic {
    var dataType: TimeSeriesDataRead.DataType { return Self.dataType }
    
    func processTimeSeriesRead(_ data: Data) {
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
        
        let start = self.readStart.addingTimeInterval(Double(millisecondOffset) / 1000.0)
        let period: Double = 1.0 / Double(freq)
        
        BLELogger.info("""
            Processing \(self.name) Data
                - Number of samples: \(numSamples)
                - Offset: \(millisecondOffset)
                - Frequency: \(freq)
        """)
        
        var dataRead = TimeSeriesDataRead(
            dataType: dataType,
            frequency: freq,
            millisecondOffset: Int(millisecondOffset),
            startTime: start,
            numSamples: numSamples,
            eventId: nil
        )
        
        do {
            try dataRead.save()
            
            for (i, rawVal) in values.reversed().enumerated() {
                var val: Double
                
                if dataType == .temperature {
                    val = Double(rawVal) / 100.0
                } else if dataType == .pressure {
                    val = (Double(rawVal) + 80000) / 100
                } else {
                    val = Double(rawVal)
                }
                
                var measurement = TimeSeriesMeasurement(
                    id: nil,
                    value: val,
                    date: start.addingTimeInterval(-(period*Double(i))),
                    dataReadId: dataRead.id,
                    eventId: nil
                )
                
                // FIXME: insert entire array
                try measurement.save()
            }
            
        } catch {
            PersistanceLogger.error("Cannot insert \(self.name): \(error.localizedDescription)")
        }
    }
}

class PressureCharacteristic: FaceBitReadCharacteristic, TimeSeriesCharacteristic {
    static var dataType: TimeSeriesDataRead.DataType = .pressure
    
    static let name = "Pressure"
    static let uuid = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8781")
    static let readValue = 1
    var readStart: Date = Date()
    
    func processRead(_ data: Data) {
        processTimeSeriesRead(data)
    }
    
}

class TemperatureCharacteristic: FaceBitReadCharacteristic, TimeSeriesCharacteristic {
    static var dataType: TimeSeriesDataRead.DataType = .temperature
    
    static let name = "Temperature"
    static let uuid = CBUUID(string: "0F1F34A3-4567-484C-ACA2-CC8F662E8782")
    static let readValue = 2
    var readStart: Date = Date()
    
    func processRead(_ data: Data) {
        processTimeSeriesRead(data)
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
        let state = State(rawValue: Int(value))
        BLELogger.info("value from mask on/off characteristic: \(value), timestamp: \(timestamp)")

        var ts = Timestamp(
            id: nil,
            dataType: state == .on ? .maskOn : .maskOff,
            date: Date()
        )
        do {
            try ts.save()
        } catch {
            PersistanceLogger.error("unable to save timestamp: \(error.localizedDescription)")
        }
       
    }
}
