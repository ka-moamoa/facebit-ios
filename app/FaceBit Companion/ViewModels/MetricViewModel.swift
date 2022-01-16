//
//  MetricPub.swift
//  FaceBit Companion
//
//  Created by blaine on 2/13/21.
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
import Combine
import SQLite3
import GRDB

class MetricViewModel: ObservableObject {
    
    @Published var items: [MetricMeasurementDetailed] = []
    
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
                .asRequest(of: MetricMeasurementDetailed.self)
                .fetchAll(db)
        } catch {
            PersistanceLogger.error("unable to fetch measurements from observer \(self.dataType.rawValue): \(error.localizedDescription)")
        }
    }
}
