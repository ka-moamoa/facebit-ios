//
//  Measurement.swift
//  FaceBit Companion
//
//  Created by blaine on 1/15/21.
//

import Foundation


struct TimeSeriesMeasurement: Codable {
    let value: Double
    let date: Date
    
    static func sampleSeries() -> [TimeSeriesMeasurement] {
        let startValue = 1.0
        let startDate = Date()
        
        
        var series: [TimeSeriesMeasurement] = []
        (0..<100).forEach { (i) in
            series.append(TimeSeriesMeasurement(value: startValue*Double(i*2), date: startDate + Double(i)))
        }
        
        
        return series
    }
}
