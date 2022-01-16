//
//  Mask_New.swift
//  FaceBit Companion
//
//  Created by blaine on 3/12/21.
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
import GRDB

struct Mask: Identifiable, Equatable, Codable {
    enum MaskType: String, Identifiable, CaseIterable, Codable, DatabaseValueConvertible {
        case n95 = "N95"
        case kn95 = "KN95"
        case surgical = "Surgical"
        case cloth = "Cloth"
        case other = "Other"
        
        var id: String { return self.rawValue }
    }
    
    var id: Int64?
    let maskType: MaskType
    let desiredWearHours: Int
    let startDate: Date
    var disposeDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case maskType = "mask_type"
        case desiredWearHours = "desired_wear_hours"
        case startDate = "start_date"
        case disposeDate = "dispose_date"
    }
    
    // MARK: - Calculated Properties
    
    var elapsedTime: TimeInterval {
        let currentTime = Date()
        return currentTime.timeIntervalSince(startDate)
    }
    
    var wearTimeString: String {
        let hours = floor(elapsedTime / 60 / 60)
        let minutes = floor((elapsedTime - (hours * 60 * 60)) / 60)
        return "\(String(format: "%02d", Int(hours))):\(String(format: "%02d", Int(minutes)))"
    }
    
    var percentValue: Float {
        let percent = Float(elapsedTime) / Float(desiredWearHours * 60 * 60)
        return min(1.0, percent)
    }
    
    // MARK: - Mutating Methods
    
    mutating func dispose() {
        self.disposeDate = Date()
        try? self.save()
    }
}

extension Mask: TableRecord {
    static var databaseTableName: String = "mask"
}

extension Mask: FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let maskType = Column(CodingKeys.maskType)
        static let desiredWearHours = Column(CodingKeys.desiredWearHours)
        static let startDate = Column(CodingKeys.startDate)
        static let disposeDate = Column(CodingKeys.disposeDate)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        self.id = rowID
    }
}

extension Mask: SQLSchema {
    static func create(in db: Database) throws {
        try db.create(table: Self.databaseTableName, body: { (t) in
            t.autoIncrementedPrimaryKey(CodingKeys.id.rawValue)
            t.column(CodingKeys.maskType.rawValue, .text).notNull()
            t.column(CodingKeys.desiredWearHours.rawValue, .integer).notNull()
            t.column(CodingKeys.startDate.rawValue, .datetime).notNull()
            t.column(CodingKeys.disposeDate.rawValue, .datetime)
        })
    }
}
