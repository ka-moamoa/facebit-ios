//
//  MetricPub.swift
//  FaceBit Companion
//
//  Created by blaine on 2/13/21.
//

import Foundation
import Combine
import SQLite3

class MetricPub: ObservableObject {
    
    @Published var items: [MetricMeasurement] = []
    
    var query: String {
        return """
            SELECT id, value, timestamp, data_type, date
            FROM metric_measurement
            WHERE data_type = '\(dataType.rawValue)'
            ORDER BY date DESC
            LIMIT \(rowLimit)
        """
    }
    
    internal var timer: Timer?
    let timerInterval: TimeInterval
    
    
    let dataType: MetricMeasurement.DataType
    let rowLimit: Int
    
    
    init(dataType: MetricMeasurement.DataType, rowLimit: Int=1, timerInterval: TimeInterval=10) {
        self.dataType = dataType
        self.rowLimit = rowLimit
        self.timerInterval = timerInterval
    }
    
    func refresh() {
        SQLiteDatabase.queue.async {
            guard let db = SQLiteDatabase.main,
                let statement = try? db.prepareStatement(sql: self.query, dbPointer: db.dbPointer) else{
                return
            }
            
            defer {
                sqlite3_finalize(statement)
            }
            
            var measurements: [MetricMeasurement] = []
            
            while sqlite3_step(statement) == SQLITE_ROW  {
                let id = Int(sqlite3_column_int(statement, 0))
                let value = sqlite3_column_double(statement, 1)
                let timestamp = UInt64(sqlite3_column_int(statement, 2))
                
                guard let dataTypeCString = sqlite3_column_text(statement, 3),
                      let dateCString = sqlite3_column_text(statement, 4),
                      let dataType = MetricMeasurement.DataType(rawValue: String(cString: dataTypeCString)),
                      let date = SQLiteDatabase.dateFormatter.date(from: String(cString: dateCString)) else {
                    continue
                }
                
                measurements.append(
                    MetricMeasurement(
                        id: id,
                        value: value,
                        dataType: dataType,
                        timestamp: timestamp,
                        date: date,
                        isInserted: true
                    )
                )
            }
            
            DispatchQueue.main.async {
                self.items = measurements
            }
        }
    }
}

extension MetricPub: TimerPublisher {
    func start() {
        timer = Timer.scheduledTimer(
            withTimeInterval: timerInterval,
            repeats: true,
            block: onFire
        )
        timer!.fire()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    internal func onFire(_ timer: Timer) {
        DispatchQueue.main.async { self.refresh() }
    }
}
