//
//  Timestamp.swift
//  FaceBit Companion
//
//  Created by blaine on 2/12/21.
//

import Foundation

class Timestamp: SQLiteTable {
    enum DataType: String, CaseIterable, Identifiable {
        case peripheralSync = "peripheral_sync"
        case maskOn = "mask_on"
        case maskOff = "mask_off"
        
        var id: String { return self.rawValue }
    }
    
    static var memId: MemoryId = MemoryId()
    static var createSQL: String = """
        CREATE TABLE IF NOT EXISTS \(Timestamp.tableName)(
            id INTEGER PRIMARY KEY NOT NULL,
            data_type TEXT NOT NULL,
            date TEXT NOT NULL
        );
    """
    static var tableName: String = "timestamp"
    
    var id: Int
    var dataType: DataType
    var date: Date
    var isInserted: Bool
    
    init(id: Int=memId.next, dataType: DataType, date: Date, isInserted:Bool=false) {
        self.id = id
        self.dataType = dataType
        self.date = date
        self.isInserted = isInserted
    }
    
    
    func insertSQL() -> String {
        return """
            INSERT INTO \(Timestamp.tableName)
            (data_type, date)
            VALUES ('\(dataType.rawValue)', '\(SQLiteDatabase.dateFormatter.string(from: date))')
        """
    }
    
    func didInsert(id: Int) {
        self.id = id
        self.isInserted = true
    }
    
    
    
    
}
