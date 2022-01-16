//
//  DatabaseTableViewModel.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
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
import GRDB

class DatabaseTableViewModel<T: FetchableRecord & MutablePersistableRecord & Codable>: ObservableObject {
    @Published var items: [T] = []
    
    private var request: QueryInterfaceRequest<T>
    private var appDatabase: AppDatabase
    private var rowLimit: Int
    
    init(appDatabase: AppDatabase, request: QueryInterfaceRequest<T>, rowLimit: Int = 100) {
        self.appDatabase = appDatabase
        self.request = request
        self.rowLimit = 100
        
        self.refresh()
    }
    
    func refresh(callback: (()->())?=nil) {
        defer { callback?() }
        try? appDatabase.dbWriter.read { (db) in
            do {
                self.items = try request
                    .limit(rowLimit)
                    .fetchAll(db)
            }
        }
    }
    
    func delete(at idx: Int) {
        let item = self.items[idx]
        try? appDatabase.dbWriter.write { (db) in
            _ = try? item.delete(db)
        }
    }
    
    func saveAndShare(fileName: String) {
        if let url = ShareUtil.saveJSON(from: DataWrapper(data: items), fileName: fileName) {
            ShareUtil.share(path: url)
        }
    }
}
