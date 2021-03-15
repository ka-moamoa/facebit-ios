//
//  Mask.swift
//  FaceBit Companion
//
//  Created by blaine on 2/14/21.
//

import Foundation
import SQLite3

class Mask: SQLiteTable {
    enum MaskType: String, Identifiable, CaseIterable {
        case n95 = "N95"
        case surgical = "Surgical"
        case cloth = "Cloth"
        case other = "Other"
        
        var id: String { return self.rawValue }
    }
    
    static var memId: MemoryId = MemoryId()
    static var createSQL: String = """
       CREATE TABLE IF NOT EXISTS \(Mask.tableName)(
           id INTEGER PRIMARY KEY NOT NULL,
           mask_type TEXT NOT NULL,
           start_date TEXT NOT NULL,
           dispose_date TEXT NOT NULL
       );
    """
    static var tableName: String = "mask"
    
    var id: Int
    var isInserted: Bool
    let maskType: MaskType
    let startDate: Date
    var disposeDate: Date?
    
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
    
    
    func insertSQL() -> String {
        return """
            INSERT INTO \(Mask.tableName)
            (mask_type, start_date, dispose_date)
            VALUES ('\(maskType.rawValue)', '\(SQLiteDatabase.dateFormatter.string(from: startDate))', '\(disposeDate == nil ? "" : SQLiteDatabase.dateFormatter.string(from: disposeDate!))');
        """
    }
    
    func didInsert(id: Int) {
        self.id = id
        self.isInserted = true
    }
    
    init(id: Int = memId.next, maskType: MaskType, startDate: Date = Date(), isInserted: Bool = false) {
        self.id = id
        self.maskType = maskType
        self.startDate = startDate
        self.isInserted = isInserted
    }
    
    func dispose(date: Date = Date()) {
        self.disposeDate = date
        
        guard isInserted else { return }
        
        let disposeDateString = SQLiteDatabase.dateFormatter.string(from: disposeDate!)
        let updateSQL = """
            UPDATE \(Mask.tableName)
            SET dispose_date = '\(disposeDateString)'
            WHERE id = \(id);
        """
        SQLiteDatabase.main?.updateRecord(record: self, updateSQL: updateSQL)
    }
    
    // MARK: - Get New
    static func getActiveMask(callback: @escaping (Mask?)->()) {
        SQLiteDatabase.queue.async {
            
            guard let db = SQLiteDatabase.main else {
                DispatchQueue.main.async { callback(nil) }
                return
            }
            let sql = """
                SELECT id, mask_type, start_date
                FROM \(Mask.tableName)
                WHERE dispose_date IS NULL or dispose_date = ''
                ORDER BY start_date DESC
                LIMIT 1
            """
            
            guard let statement = try? db.prepareStatement(sql: sql, dbPointer: db.dbPointer) else {
                DispatchQueue.main.async { DispatchQueue.main.async { callback(nil) } }
                return
            }

            defer {
                sqlite3_finalize(statement)
            }
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                
                guard
                    let maskType = MaskType(rawValue: String(cString: sqlite3_column_text(statement, 1))),
                    let startDate = SQLiteDatabase.dateFormatter.date(from: String(cString: sqlite3_column_text(statement, 2)))
                else {
                    DispatchQueue.main.async { callback(nil) }
                    return
                }
                
                let mask = Mask(
                    id: id,
                    maskType: maskType,
                    startDate: startDate,
                    isInserted: true
                )
                
                DispatchQueue.main.async {
                    callback(mask)
                }
            }
        }
    }
}
