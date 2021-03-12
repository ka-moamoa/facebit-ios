//
//  Timestamp_New.swift
//  FaceBit Companion
//
//  Created by blaine on 3/12/21.
//

import Foundation
import GRDB

struct Timestamp_New: Identifiable, Equatable, Codable {
    enum DataType: String, CaseIterable, Identifiable, Codable {
        case peripheralSync = "peripheral_sync"
        case maskOn = "mask_on"
        case maskOff = "mask_off"
        
        var id: String { return self.rawValue }
    }
    
    var id: Int64?
    let dataType: DataType
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case dataType = "data_type"
        case date = "date"
    }
}

extension Timestamp_New: TableRecord {
    static var databaseTableName: String = "timestamp"
}

extension Timestamp_New: FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let dataType = Column(CodingKeys.dataType)
        static let date = Column(CodingKeys.date)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        self.id = rowID
    }
}

extension Timestamp_New: SQLSchema {
    static func create(in db: Database) throws {
        try db.create(table: Self.databaseTableName, body: { (t) in
            t.autoIncrementedPrimaryKey(CodingKeys.id.rawValue)
            t.column(CodingKeys.dataType.rawValue, .text).notNull()
            t.column(CodingKeys.date.rawValue, .datetime).notNull()
        })
    }
}
