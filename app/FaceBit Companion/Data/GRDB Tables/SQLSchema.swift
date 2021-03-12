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
}

