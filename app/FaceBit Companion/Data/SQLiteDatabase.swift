//
//  SQLiteDatabase.swift
//  FaceBit Companion
//
//  Created by blaine on 1/15/21.
//

// reworked from: https://www.raywenderlich.com/6620276-sqlite-with-swift-tutorial-getting-started#toc-anchor-014

import Foundation
import SQLite3

enum SQLiteError: Error {
  case OpenDatabase(message: String)
  case Prepare(message: String)
  case Step(message: String)
  case Bind(message: String)
}

class SQLiteDatabase {
    private let dbPointer: OpaquePointer?
    
    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    private static var _main: SQLiteDatabase?
    
    static var dbPath: URL? {
        let dirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dbPath = dirURL?.appendingPathComponent("db.sqlite")
        return dbPath
    }
    
    static let queue = DispatchQueue(label: "sqlite-queue", qos: .userInitiated)
    
    static var main: SQLiteDatabase? {
        guard SQLiteDatabase._main == nil else {
            return _main
        }
        
        openDatabase()
        return _main
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter
    }
    
    static var tables: [SQLiteTable.Type] = [
        SmartPPEEvent.self,
        TimeSeriesDataRead.self,
        TimeSeriesMeasurement.self,
        MetricMeasurement.self
    ]
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    var errorMessage: String {
      if let errorPointer = sqlite3_errmsg(dbPointer) {
        let errorMessage = String(cString: errorPointer)
        PersistanceLogger.error("Error Message: \(errorMessage)")
        return errorMessage
      } else {
        return "No error message provided from sqlite."
      }
    }
    
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer?
        
        if sqlite3_open(path, &db) == SQLITE_OK {
            return SQLiteDatabase(dbPointer: db)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
    
    static func openDatabase(purge: Bool=false) {
        do {
            guard let path = SQLiteDatabase.dbPath?.relativePath else { return }
           
            if purge, let dbPath = SQLiteDatabase.dbPath?.relativePath,
               FileManager.default.fileExists(atPath: dbPath) {
                
                try FileManager.default.removeItem(atPath: dbPath)
            }
            
            let db = try SQLiteDatabase.open(path: path)
            PersistanceLogger.debug("Database Path: \(path)")
            PersistanceLogger.info("Successfully opened connection to database.")
            _main = db
        } catch {
            PersistanceLogger.error("Unable to open database.")
            return
        }
    }
    
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
            
        }
        
        return statement
    }
    
    func executeSQL(sql: String) {
        SQLiteDatabase.queue.async { [weak self] in
            guard let self = self else { return }
            let statement = try? self.prepareStatement(sql: sql)
            
            defer {
                sqlite3_finalize(statement)
            }
            
            guard sqlite3_step(statement) == SQLITE_DONE else {
                PersistanceLogger.error("\(self.errorMessage)")
                return
            }
        }
    }
        
    func createTable(table: SQLiteTable.Type) {
        SQLiteDatabase.queue.async { [weak self] in
            guard let self = self else { return }
            
            let createTableSQL = try? self.prepareStatement(sql: table.createSQL)
            
            defer {
                sqlite3_finalize(createTableSQL)
            }
            
            guard sqlite3_step(createTableSQL) == SQLITE_DONE else {
                PersistanceLogger.error("\(self.errorMessage)")
                return
            }
            PersistanceLogger.info("\(table) table created.")
        }
    }
    
    func insertRecord<T:SQLiteTable>(record: T, callback: ((T?)->())?=nil) {
        SQLiteDatabase.queue.async { [weak self] in
            guard let self = self else {
                callback?(nil)
                return
            }
            
            let insertStatement = try? self.prepareStatement(sql: record.insertSQL())
            
            defer {
                sqlite3_finalize(insertStatement)
            }
            
            guard sqlite3_step(insertStatement) == SQLITE_DONE else {
                PersistanceLogger.error("\(self.errorMessage)")
                callback?(nil)
                return
            }
            
            PersistanceLogger.debug("Successfully inserted \(T.tableName) row.")
            
            if let insertedId = try? self.lastInsertedId() {
                record.didInsert(id: insertedId)
                callback?(record)
            }
        }
    }
    
    func updateRecord<T:SQLiteTable>(record: T, updateSQL: String) {
        SQLiteDatabase.queue.async { [weak self] in
            guard let self = self else { return }
            
            let updateStatement = try? self.prepareStatement(sql: updateSQL)
            
            defer {
                sqlite3_finalize(updateStatement)
            }
            
            guard sqlite3_step(updateStatement) == SQLITE_DONE else {
                PersistanceLogger.error("\(self.errorMessage)")
                return
            }
            
            PersistanceLogger.info("successfully update \(T.tableName) row")
        }
        
    }
    
// Attempt at Batch Insert -- Loose id updates
//    func insertRecords<T:SQLiteTable>(records: [T]) throws {
//        let query = records.map { $0.insertSQL() }.joined(separator: " ")
//        let insertStatement = try prepareStatement(sql: query)
//        defer {
//            sqlite3_finalize(insertStatement)
//        }
//
//        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
//            throw SQLiteError.Step(message: errorMessage)
//        }
//
//        print("Successfully inserted \(T.tableName) rows")
//    }

    func lastInsertedId() throws -> Int {
        let sql = "SELECT last_insert_rowid()"
        let statement = try? prepareStatement(sql: sql)
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        let id = Int(sqlite3_column_int(statement, 0))
        
        return id
    }
    
//    func query(_ sql: String) -> OpaquePointer? {
//        guard let queryStatement = try? prepareStatement(sql: sql) else {
//            return nil
//        }
//        
//        defer {
//            sqlite3_finalize(queryStatement)
//        }
//        
//        return queryStatement
//    }
    
//    func getAllTS(from startDate: Date, to endDate: Date) -> [TimeSeriesMeasurement] {
//        let sql = """
//        SELECT id, value, date, type
//        FROM \(TimeSeriesMeasurement.tableName)
//        WHERE date >= '\(SQLiteDatabase.dateFormatter.string(from: startDate))'
//            AND date <= '\(SQLiteDatabase.dateFormatter.string(from: endDate))';
//        """
//
//        guard let queryStatement = try? prepareStatement(sql: sql) else { return [] }
//
//        defer {
//            sqlite3_finalize(queryStatement)
//        }
//
//        var measurements: [TimeSeriesMeasurement] = []
//
//        while(sqlite3_step(queryStatement) == SQLITE_ROW) {
//            let id = Int(sqlite3_column_int(queryStatement, 0))
//            let value = sqlite3_column_double(queryStatement, 1)
//
//            guard let dateCString = sqlite3_column_text(queryStatement, 2),
//                  let typeCString = sqlite3_column_text(queryStatement, 3) else {
//                continue
//            }
//
//            guard let date = SQLiteDatabase.dateFormatter.date(from: String(cString: dateCString)),
//                  let type = TimeSeriesMeasurement.DataType(rawValue: String(cString: typeCString)) else {
//                continue
//            }
//
//            measurements.append(
//                TimeSeriesMeasurement(
//                    id: id,
//                    value: value,
//                    date: date,
//                    type: type,
//                    isInserted: true
//                )
//            )
//        }
//        return measurements
//    }
}
