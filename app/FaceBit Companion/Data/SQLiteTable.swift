//
//  SQLiteTable.swift
//  FaceBit Companion
//
//  Created by blaine on 1/18/21.
//

import Foundation

protocol SQLiteTable {
    static var memId: MemoryId { get }
    static var createSQL: String { get }
    static var tableName: String { get }
    
    var isInserted: Bool { get }
    var id: Int { get }
    
    func insertSQL() -> String
    func didInsert(id: Int)
}
