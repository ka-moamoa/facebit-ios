//
//  AppDatabase.swift
//  FaceBit Companion
//
//  Created by blaine on 3/11/21.
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

class DatabaseCreationError: Error { }

struct AppDatabase {
    let dbWriter: DatabaseWriter
    
    init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // in development, delete everything on database change
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("create-event") { (db) in
            try Event.create(in: db)
            try TimeSeriesDataRead.create(in: db)
            try TimeSeriesMeasurement.create(in: db)
            try Timestamp.create(in: db)
            try Mask.create(in: db)
            try MetricMeasurement.create(in: db)
        }
        
        return migrator
    }
}

extension AppDatabase {
    static let shared = makeShared()
    
    static var dbFolderPath: URL? {
        let fileManager = FileManager()
        let folderPath = try? fileManager
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("database", isDirectory: true)
        
        return folderPath
    }
    
    static var dbPath: URL? {
        guard let folderPath = dbFolderPath else { return nil }
        let dbPath = folderPath.appendingPathComponent("db.sqlite")
        return dbPath
    }
    
    private static func makeShared() -> AppDatabase {
        do {
            guard let folderPath = dbFolderPath,
                  let dbPath = dbPath else { throw DatabaseCreationError() }
            
            let fileManager = FileManager()
            try fileManager.createDirectory(at: folderPath, withIntermediateDirectories: true)
            PersistanceLogger.info("Database Path: \(dbPath)")
            
            var configuration = Configuration()
            configuration.qos = DispatchQoS.userInitiated
            
            let dbPool = try DatabasePool(path: dbPath.path, configuration: configuration)
            
            let appDatabase = try AppDatabase(dbPool)
            
            return appDatabase
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }
    
    static func empty() -> AppDatabase {
        // Connect to an in-memory database
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
        let dbQueue = DatabaseQueue()
        return try! AppDatabase(dbQueue)
    }
    
    func purge() throws {
        try dbWriter.write { (db) in
            try Timestamp.deleteAll(db)
            try TimeSeriesDataRead.deleteAll(db)
            try TimeSeriesMeasurement.deleteAll(db)
            try Mask.deleteAll(db)
            try MetricMeasurement.deleteAll(db)
            try Event.deleteAll(db)
        }
    }
}
