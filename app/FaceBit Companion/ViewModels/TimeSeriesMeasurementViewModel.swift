//
//  TimeSeriesMeasurementPub.swift
//  FaceBit Companion
//
//  Created by blaine on 2/2/21.
//

import Foundation
import Combine
import SQLite3
import GRDB

class TimeSeriesMeasurementViewModel: ObservableObject {
    @Published var items: [TimeSeriesMeasurementDetailed] = []
    
    private let appDatabase: AppDatabase
    private let dataType: TimeSeriesDataRead.DataType
    private let rowLimit: Int
    private let timeOffset: TimeInterval
    
    private var observer: TransactionObserver?
    private static var readQueue = DispatchQueue(label: "timeseriespub", qos: .background)
    
    private var lastUpdate: Date = Date().addingTimeInterval(-3)
    
    init(
        appDatabase: AppDatabase,
        dataType: TimeSeriesDataRead.DataType,
        rowLimit: Int=100,
        timeOffset: TimeInterval=5
    ) {
        
        self.appDatabase = appDatabase
        self.dataType = dataType
        self.rowLimit = rowLimit
        self.timeOffset = timeOffset
        
        try? appDatabase.dbWriter.read { (db) in
            self.refresh(with: db)
        }
        
        self.observer = try? observation().start(in: appDatabase.dbWriter, onChange: { (db) in
            self.refresh(with: db)
        })
    }
    
    func observation() -> DatabaseRegionObservation {
        return DatabaseRegionObservation(
            tracking: TimeSeriesDataRead
                .filter(TimeSeriesDataRead.Columns.dataType == dataType)
        )
    }
    
    func refresh(with db: Database) {
        do {
            self.items = try TimeSeriesMeasurement
                .filter(Column("date") < Date().addingTimeInterval(-timeOffset))
                .including(optional: TimeSeriesMeasurement.event)
                .including(
                    required: TimeSeriesMeasurement.dataRead.filter(Column("data_type") == dataType.rawValue)
                )
                .order(TimeSeriesMeasurement.Columns.date.desc)
                .limit(rowLimit)
                .asRequest(of: TimeSeriesMeasurementDetailed.self)
                .fetchAll(db)
        } catch {
            PersistanceLogger.error("unable to fetch measurements from observer \(self.dataType.rawValue): \(error.localizedDescription)")
        }
    }
}
