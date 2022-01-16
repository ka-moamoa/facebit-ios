//
//  LiveLinePlot.swift
//  FaceBit Companion
//
//  Created by blaine on 1/15/21.
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

import SwiftUI

struct LiveLinePlot: View {
    @Binding var timeSeries: [TimeSeriesMeasurementDetailed]
    @State var showAxis: Bool
    @State var maxTicks: Int = 25
    @State var xOffset: CGFloat = 0.1
    @State var yOffset: CGFloat = 0.1
    
    func NormalizedTimeSeries() -> [(point: CGPoint, measurement: TimeSeriesMeasurement)] {
        
        let series = Array(timeSeries.reversed().prefix(maxTicks).reversed())
        
        let values = Array(Array(series.map({ $0.timeSeriesMeasurement.value }).reversed().prefix(maxTicks)).reversed())
        let dates = Array(Array(series.map({ $0.timeSeriesMeasurement.date }).reversed().prefix(maxTicks)).reversed())
        
        guard values.count > 0 else { return [] }
         
        let maxValue = values.max()!
        let minValue = values.min()!
        
        let startDate = dates.min()!
        let endDate = dates.max()!
        
        let timeStart = 0.0
        let timeEnd = startDate.distance(to: endDate)
        
        var normalized: [(point: CGPoint, measurement: TimeSeriesMeasurement)] = []
        
        series.forEach({ (m) in
            normalized.append(
                (
                    point: CGPoint(
                        x: (startDate.distance(to: m.timeSeriesMeasurement.date) - timeStart) / (timeEnd - timeStart),
                        y: (m.timeSeriesMeasurement.value - minValue) / ((maxValue - minValue) + Double.leastNonzeroMagnitude)
                    ),
                    measurement: m.timeSeriesMeasurement
                )
            )
        })
        return normalized
    }
    
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            if timeSeries.count > 0 {
                let normalizedTimeSeries = NormalizedTimeSeries()
                
                Path() { path in
                    
                    let startX: CGFloat = normalizedTimeSeries[0].point.x
                    let startY: CGFloat = normalizedTimeSeries[0].point.y
                    
                    path.move(to:
                            CGPoint(
                                x: startX * (width * 0.8) + geometry.size.width * xOffset,
                                y: height - (startY * (height * 0.8) + height * yOffset)
                        )
                    )
                    for measurement in normalizedTimeSeries {
                        path.addLine(
                            to:
                                CGPoint(
                                    x: measurement.point.x * (width * 0.8) + geometry.size.width * xOffset,
                                    y: height - (measurement.point.y * (height * 0.8) + height * yOffset)
                                )
                        )
                    }
                }
                .stroke(Color("PrimaryBrown"), lineWidth: 2)
                
                if showAxis {
                    
                    Path() { path in
                        path.move(
                            to: CGPoint(
                                x: width * xOffset,
                                y: height * yOffset)
                        )
                        
                        path.addLine(
                            to: CGPoint(
                                x: width * xOffset,
                                y: height * (1.0 - yOffset))
                        )
                        
                        path.addLine(
                            to: CGPoint(
                                x: width * (1.0-xOffset),
                                y: height * (1.0-yOffset))
                        )
                    }
                    .stroke(Color.blue)
                
                    let yTicks: Int = 8
                    let maxValue: Double = NormalizedTimeSeries().map({$0.measurement.value}).max()!
                    let minValue: Double = NormalizedTimeSeries().map({$0.measurement.value}).min()!
                    let yUnit: Double = (maxValue - minValue) / Double(yTicks)

                    ForEach(0..<yTicks) { mark in
                        let num: Double = Double(mark) == 0.0 ? minValue : minValue + (yUnit * Double(mark))

                        Text(String(format: "%.2f", num))
                            .font(.system(size: 12))
                            .offset(
                                x: (width * 0.05),
                                y: ((height * yOffset) * CGFloat(yTicks - mark)) + (height * yOffset) - 3.0
                            )
                        Rectangle()
                            .fill(Color.gray)
                            .offset(
                                x: (width * xOffset) - 3.0,
                                y: ((height * yOffset) * CGFloat(yTicks - mark)) + (height * yOffset) - 1.0
                            )
                            .frame(width: 6.0, height: 2.0)
                    }
                    
                    let xTicks = 8
                    
                    let maxDate: Date = NormalizedTimeSeries().map({$0.measurement.date}).max()!
                    let minDate: Date = NormalizedTimeSeries().map({$0.measurement.date}).min()!
                    let minSeconds: Double = maxDate.distance(to: minDate)
                    let xUnit = minSeconds / Double(yTicks)
                    
                    ForEach(0..<xTicks) { mark in
                        let num: Double = Double(mark) == 0.0 ? minSeconds : minSeconds + (xUnit * Double(mark))
                        
                        Text(String(format: "%.1f", num))
                            .font(.system(size: 12))
                            .offset(
                                x: ((width * xOffset) * CGFloat(xTicks - mark)) - 3.0,
                                y: height - (height * 0.05)
                            )
                        Rectangle()
                            .fill(Color.gray)
                            .offset(
                                x: (width * xOffset) * CGFloat(xTicks - mark) - 1.0,
                                y: height - (height * yOffset) - 3.0
                            )
                            .frame(width: 2.0, height: 6.0)
                    }
                }
            }
        }
        
    }
}

struct LiveLinePlot_Previews: PreviewProvider {
    @State static var timeSeries: [TimeSeriesMeasurementDetailed] = []
    
    static var previews: some View {
        LiveLinePlot(
            timeSeries: $timeSeries,
            showAxis: true,
            maxTicks: 10,
            xOffset: 0.2,
            yOffset: 0.2
        )
    }
}
