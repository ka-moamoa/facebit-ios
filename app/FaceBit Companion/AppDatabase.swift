//
//  AppDatabase.swift
//  FaceBit Companion
//
//  Created by blaine on 3/11/21.
//

import Foundation
import Combine
import GRDB

struct AppDatabase {
    private let dbWriter: DatabaseWriter
    
    init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // in develoopment, delete everything on database change
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("create-event") { (db) in
            try Event.create(in: db)
            try TimeSeriesDataRead_New.create(in: db)
            try TimeSeriesMeasurement_New.create(in: db)
        }
        
//        TODO: TimeSeriesMeasurement Table
//        TODO: Metric Measurement Table
//        TODO: Timestamp Table
//        TODO: Mask Table
        
        return migrator
    }
}

extension AppDatabase {
    static let shared = makeShared()
    
    private static func makeShared() -> AppDatabase {
        do {
            let fileManager = FileManager()
            let folderPath = try fileManager
                .url(for: .applicationDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("database", isDirectory: true)
            try fileManager.createDirectory(at: folderPath, withIntermediateDirectories: true)
            
            let dbPath = folderPath.appendingPathComponent("db.sqlite")
            PersistanceLogger.info("Database Path: \(dbPath)")
            
            let dbPool = try DatabasePool(path: dbPath.path)
            
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
}

extension AppDatabase {
    func insert(_ record: inout Event) throws {
        try dbWriter.write({ (db) in
            try record.save(db)
        })
    }
}
