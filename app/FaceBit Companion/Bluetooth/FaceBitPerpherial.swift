//
//  Perpherial.swift
//  FaceBit Companion
//
//  Created by blaine on 1/14/21.
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
    
    private var currentEvent: Event?
    
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
    
    func setEvent(_ event: Event?=nil) {
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
        
        BLELogger.debug("Did update value for characteristic: \(characteristic.uuid.uuidString)")
        
        switch characteristic.uuid {
        case DataReadyCharacteristicUUID:
            handleReadReady(value)            
        default:
            if let c = readChars.first(where: { $0.uuid == characteristic.uuid }) {
                updateReadReady(DataReadyNoData, peripheral: peripheral)
                c.processRead(value)
            } else {
                print("Unhandled Characteristic UUID: \(characteristic.uuid)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print()
    }
    
    private func updateTimeSync(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        let now = Date()
        let timestamp: UInt64 = UInt64(now.timeIntervalSince1970.rounded())
        let data = Data(timestamp.toBytes)
        
        BLELogger.info("Writting Timestamp: \(timestamp)")
        
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        
        var ts = Timestamp(
            id: nil,
            dataType: .peripheralSync,
            date: now
        )
        
        do {
            try ts.save()
        } catch {
            PersistanceLogger.error("unable to save timestamp: \(error.localizedDescription)")
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        BLELogger.debug("Did update notification state for: \(characteristic.uuid.uuidString), \(error?.localizedDescription ?? "no error")")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        BLELogger.debug("Did write value for \(characteristic.uuid.uuidString), \(error?.localizedDescription ?? "no error")")
    }
    
    private func updateReadReady(_ data: Data, peripheral: CBPeripheral) {
        guard let service = peripheral.services?.first(where: { $0.uuid == mainServiceUUID }) else {
            return
        }
        
        if let readReadyChar = service.characteristics?.first(where: { $0.uuid == DataReadyCharacteristicUUID }) {
            BLELogger.info("Writing Data Ready: NO_DATA")
            peripheral.writeValue(DataReadyNoData, for: readReadyChar, type: .withoutResponse)
//            peripheral.readValue(for: readReadyChar)
        }
    }
    
    private func handleReadReady(_ data: Data) {
        let readValue = Int([UInt8](data)[0])
        
        BLELogger.info("Data Ready Value: \(readValue)")
        
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
}
