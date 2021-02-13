//
//  MetricMeasurement.swift
//  FaceBit Companion
//
//  Created by blaine on 2/11/21.
//

import Foundation


class MetricMeasurement: Codable, SQLiteTable {
    enum DataType: String, CaseIterable, Identifiable, Codable {
        case respiratoryRate = "respiratory_rate"
        case heartRate = "heart_rate"
        
        var id: String { return self.rawValue }
    }
    
    static var memId: MemoryId = MemoryId()
    
    static var createSQL: String {
        return """
            CREATE TABLE IF NOT EXISTS \(MetricMeasurement.tableName)(
                id INTEGER PRIMARY KEY NOT NULL,
                value REAL NOT NULL,
                data_type TEXT NOT NULL,
                timestamp INTEGER NOT NULL,
                date TEXT NOT NULL
            );
        """
    }
    
    static var tableName: String = "metric_measurement"
    
    var isInserted: Bool
    var id: Int
    
    var value: Double
    var dataType: DataType
    var timestamp: UInt64
    var date: Date
    
    init(
        id:Int=memId.next,
        value: Double,
        dataType: DataType,
        timestamp: UInt64,
        date: Date=Date(),
        isInserted: Bool=false
    ) {
        
        self.id = id
        self.value = value
        self.dataType = dataType
        self.timestamp = timestamp
        self.date = date
        self.isInserted = isInserted
    }
    
    func insertSQL() -> String {
        return """
            INSERT INTO \(MetricMeasurement.tableName)
            (value, data_type, timestamp, date)
            VALUES (\(self.value), '\(self.dataType)', \(self.timestamp), '\(SQLiteDatabase.dateFormatter.string(from: self.date))');
        """
    }
    
    func didInsert(id: Int) {
        self.id = id
        self.isInserted = true
    }
    
    
}
