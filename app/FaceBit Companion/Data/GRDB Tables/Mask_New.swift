//
//  Mask_New.swift
//  FaceBit Companion
//
//  Created by blaine on 3/12/21.
//

import Foundation
import GRDB

struct Mask_New: Identifiable, Equatable, Codable {
    enum MaskType: String, Identifiable, CaseIterable, Codable {
        case n95 = "N95"
        case surgical = "Surgical"
        case cloth = "Cloth"
        case other = "Other"
        
        var id: String { return self.rawValue }
    }
    
    var id: Int64?
    let maskType: MaskType
    let startDate: Date
    var disposeDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case maskType = "mask_type"
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
        let percent = Float(elapsedTime) / Float(8 * 60 * 60)
        return min(1.0, percent)
    }
}

extension Mask_New: TableRecord {
    static var databaseTableName: String = "mask"
}

extension Mask_New: FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let maskType = Column(CodingKeys.maskType)
        static let startDate = Column(CodingKeys.startDate)
        static let disposeDate = Column(CodingKeys.disposeDate)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        self.id = rowID
    }
}

extension Mask_New: SQLSchema {
    static func create(in db: Database) throws {
        try db.create(table: Self.databaseTableName, body: { (t) in
            t.autoIncrementedPrimaryKey(CodingKeys.id.rawValue)
            t.column(CodingKeys.maskType.rawValue, .text).notNull()
            t.column(CodingKeys.startDate.rawValue, .datetime).notNull()
            t.column(CodingKeys.disposeDate.rawValue, .datetime)
        })
    }
}
