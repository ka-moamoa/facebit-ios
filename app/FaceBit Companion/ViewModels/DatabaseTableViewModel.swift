//
//  DatabaseTableViewModel.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

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
