//
//  MaskPub.swift
//  FaceBit Companion
//
//  Created by blaine on 2/14/21.
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
