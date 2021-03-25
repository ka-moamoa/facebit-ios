//
//  MaskPub.swift
//  FaceBit Companion
//
//  Created by blaine on 2/14/21.
//

import Foundation
import Combine
import SQLite3
import GRDB

class MaskViewModel: ObservableObject {
    private let appDatabase: AppDatabase
    @Published var mask: Mask?
    
    private var timestamps: [Timestamp] = []
    
    init(db: AppDatabase) {
        self.appDatabase = db
        loadMask()
    }
    
    func loadMask() {
        do {
            self.mask = try appDatabase.dbWriter.read { (db) in
                try Mask
                    .filter(Mask.Columns.disposeDate == nil)
                    .order(Mask.Columns.startDate.desc)
                    .fetchOne(db)
            }
        } catch {
            PersistanceLogger.error("Could not load Mask: \(error.localizedDescription)")
        }
    }
    
    func createMask(of maskType: Mask.MaskType, wearHours: Int) {
        var mask = Mask(
            id: nil,
            maskType: maskType,
            desiredWearHours: wearHours,
            startDate: Date(),
            disposeDate: nil
        )
        try? mask.save()
        self.mask = mask
    }
    
    func disposeMask() {
        self.mask?.dispose()
        self.mask = nil
    }
    
    func loadTimestamps(for mask: Mask) {
        
        self.mask = mask
        do {
            self.timestamps = try appDatabase.dbWriter.read({ (db) in
                try Timestamp
                    .filter(Timestamp.Columns.date > mask.startDate &&
                    (Timestamp.Columns.dataType == Timestamp.DataType.maskOn.rawValue ||
                        Timestamp.Columns.dataType == Timestamp.DataType.maskOff.rawValue))
                    .order(Timestamp.Columns.date.asc)
                    .fetchAll(db)
            })
        } catch {
            PersistanceLogger.error("Unable to load timestamps: \(error.localizedDescription)")
        }
    }
}
