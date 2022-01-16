//
//  HeartRateWidget.swift
//  FaceBit Companion
//
//  Created by blaine on 2/13/21.
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

struct MetricWidget: View {
    var title: String
    var unit: String
    
    @ObservedObject private var publisher: MetricViewModel
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    init(
        title: String,
        unit: String,
        dataType: MetricMeasurement.DataType,
        timerInterval: TimeInterval
    ) {
        
        self.title = title
        self.unit = unit
        self.publisher = MetricViewModel(
            appDatabase: AppDatabase.shared,
            dataType: dataType,
            rowLimit: 1
        )
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }
    
    private var lastReadDate: String {
        if let date = publisher.items.last?.metric.date {
            return dateFormatter.string(from: date)
        }
        
        return "No Readings"
    }
    
    private var lastValue: Double {
        return publisher.items.last?.metric.value ?? 0.0
    }
    
    var body: some View {
        WidgetView {
            VStack {
                Text(title)
                    .bold()
                Spacer()
                Text("\(String(format: "%.0f", lastValue))")
                    .font(.system(size: 34.0))
                    .fontWeight(.bold)
                    .padding(8)
                Text(unit)
                    .font(.system(size: 16.0))
                Spacer()
                
                Text(lastReadDate)
                    .font(.system(size: 11.0))
                    
            }
        }
    }
}

struct HeartRateWidget_Previews: PreviewProvider {
    static var previews: some View {
        MetricWidget(
            title: "Metric",
            unit: "bpm",
            dataType: .heartRate,
            timerInterval: 10
        )
    }
}
