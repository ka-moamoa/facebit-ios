//
//  SQLSchema.swift
//  FaceBit Companion
//
//  Created by blaine on 3/12/21.
//

import Foundation
import GRDB

protocol SQLSchema {
    static func create(in db: Database) throws
    
    mutating func save(into dbWriter: DatabaseWriter) throws
}

extension SQLSchema where Self:MutablePersistableRecord {
    mutating func save(into dbWriter: DatabaseWriter=AppDatabase.shared.dbWriter) throws {
        try dbWriter.write({ (db) in
            try self.save(db)
        })
    }
}
