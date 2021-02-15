//
//  MaskPub.swift
//  FaceBit Companion
//
//  Created by blaine on 2/14/21.
//

import Foundation
import Combine


class MaskViewModel: ObservableObject {
    @Published var mask: Mask?
    private var timestamps: [Timestamp] = []
    
    init() {
        loadMask()
    }
    
    func loadMask() {
        Mask.getActiveMask() { (mask) in
            self.mask = mask
//            defer { self.mask = mask }
            if mask != nil {
                
            }
        }
    }
    
    func createMask(of maskType: Mask.MaskType) {
        let mask = Mask(
            maskType: maskType,
            startDate: Date(),
            isInserted: false
        )
        SQLiteDatabase.main?.insertRecord(record: mask)
        self.mask = mask
    }
    
    func disposeMask() {
        guard let mask = mask else { return }
        
        mask.dispose()
        self.mask = nil
    }
    
    func loadTimestamps(for mask: Mask) {
//        SQLiteDatabase.queue.async {
//            let dateString = SQLiteDatabase.dateFormatter.string(from: mask.startDate)
//
//            let query = """
//                SELECT id, data_type, date
//            """
//        }
    }
}
