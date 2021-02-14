//
//  DatabaseConnection.swift
//  FaceBit Companion
//
//  Created by blaine on 2/13/21.
//

import Foundation
import SQLite3

protocol DatabaseConnection {
    static var queue: DispatchQueue { get }
    static var dbPointer: OpaquePointer? { get }
}

extension DatabaseConnection {
    func errorMessage(_ dbPointer: OpaquePointer?) -> String {
      if let errorPointer = sqlite3_errmsg(dbPointer) {
        let errorMessage = String(cString: errorPointer)
        PersistanceLogger.error("Error Message: \(errorMessage)")
        return errorMessage
      } else {
        return "No error message provided from sqlite."
      }
    }
    
    func prepareStatement(sql: String, dbPointer: OpaquePointer?) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage(dbPointer))
            
        }
        
        return statement
    }
}

//extension DatabaseConnection {
//    struct Static {
//    static var queue: DispatchQueue {
//        return DispatchQueue(label: "sqlite-conn-\(String(describing: type(of: Self.self)))", qos: .userInitiated)
//    }
//    
//    static var dbPointer: OpaquePointer? {
//        guard let path = SQLiteDatabase.dbPath?.relativePath else{
//            return nil
//        }
//        return try? SQLiteDatabase.open(path: path)
//    }
//}
