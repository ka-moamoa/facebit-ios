//
//  MetricPub.swift
//  FaceBit Companion
//
//  Created by blaine on 2/13/21.
//

import Foundation
import Combine
import SQLite3
import GRDB

class MetricViewModel: ObservableObject {
    
    @Published var items: [MetricMeasurementInfo] = []
    
    private let appDatabase: AppDatabase
    private let dataType: MetricMeasurement.DataType
    private let rowLimit: Int
    
    private var observer: TransactionObserver?
    
    init(appDatabase: AppDatabase, dataType: MetricMeasurement.DataType, rowLimit: Int=1) {
        self.appDatabase = appDatabase
        self.dataType = dataType
        self.rowLimit = rowLimit
        
        try? appDatabase.dbWriter.read { (db) in
            self.refresh(with: db)
        }
        
        self.observer = try? observation().start(in: appDatabase.dbWriter, onChange: { (db) in
            self.refresh(with: db)
        })
    }
    
    func observation() -> DatabaseRegionObservation {
        return DatabaseRegionObservation(
            tracking: MetricMeasurement
                .filter(MetricMeasurement.Columns.dataType == dataType)
        )
    }
    
    func refresh(with db: Database) {
        do {
            self.items = try MetricMeasurement
                .filter(MetricMeasurement.Columns.dataType == self.dataType.rawValue)
                .including(optional: MetricMeasurement.event)
                .limit(rowLimit)
                .asRequest(of: MetricMeasurementInfo.self)
                .fetchAll(db)
        } catch {
            PersistanceLogger.error("unable to fetch measurements from observer \(self.dataType.rawValue): \(error.localizedDescription)")
        }
    }
}
