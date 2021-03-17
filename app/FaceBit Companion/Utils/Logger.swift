//
//  Logger.swift
//  FaceBit Companion
//
//  Created by blaine on 1/18/21.
//

import Foundation
import OSLog

let GeneralLogger = Logger(subsystem: "com.kamoamoa.smartppe.FaceBit-Companion", category: "general")

let PersistanceLogger = Logger(subsystem: "com.kamoamoa.smartppe.FaceBit-Companion", category: "persistance")
let BLELogger = Logger(subsystem: "com.kamoamoa.smartppe.FaceBit-Companion", category: "ble")
let InferenceLogger = Logger(subsystem: "com.kamoamoa.smartppe.FaceBit-Companion", category: "inference")
