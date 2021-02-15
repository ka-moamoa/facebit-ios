//
//  MaskPub.swift
//  FaceBit Companion
//
//  Created by blaine on 2/14/21.
//

import Foundation
import Combine
import SQLite3

class MaskViewModel: ObservableObject {
    @Published var mask: Mask?
    private var timestamps: [Timestamp] = []
    
    init() {
        loadMask()
    }
    
    func loadMask() {
        Mask.getActiveMask() { (mask) in
            self.mask = mask
            if mask != nil {
                self.loadTimestamps(for: mask!)
            }
        }
    }
    
    func createMask(of maskType: Mask.MaskType) {
        let mask = Mask(
            maskType: maskType,
            startDate: Date(),
            isInserted: false
        )
        SQLiteDatabase.main?.insertRecord(record: mask)
        self.mask = mask
    }
    
    func disposeMask() {
        guard let mask = mask else { return }
        
        mask.dispose()
        self.mask = nil
    }
    
    func loadTimestamps(for mask: Mask) {
        SQLiteDatabase.queue.async {
            let dateString = SQLiteDatabase.dateFormatter.string(from: mask.startDate)

            let query = """
                SELECT id, data_type, date
                FROM timestamp
                WHERE date > '\(dateString)'
                    AND (data_type == '\(Timestamp.DataType.maskOn.rawValue)'
                        OR data_type == '\(Timestamp.DataType.maskOff.rawValue)')
                ORDER BY date ASC;
            """
            
            guard let db = SQLiteDatabase.main,
                  let statement = try? db.prepareStatement(sql: query, dbPointer: db.dbPointer) else {
                return
            }
            
            defer {
                sqlite3_finalize(statement)
            }
            
            var timestamps: [Timestamp] = []
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                
                guard let dataType = Timestamp.DataType(rawValue: String(cString: sqlite3_column_text(statement, 1))),
                      let date = SQLiteDatabase.dateFormatter.date(from: String(cString: sqlite3_column_text(statement, 2))) else {
                    continue
                }
                
                timestamps.append(
                    Timestamp(
                        id: id,
                        dataType: dataType,
                        date: date,
                        isInserted: true
                    )
                )
            }
            
            DispatchQueue.main.async {
                self.timestamps = timestamps
                self.mask = mask
            }
        }
    }
}
