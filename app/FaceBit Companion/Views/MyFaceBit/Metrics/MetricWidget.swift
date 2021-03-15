//
//  HeartRateWidget.swift
//  FaceBit Companion
//
//  Created by blaine on 2/13/21.
//

import SwiftUI

struct MetricWidget: View {
    var title: String
    var unit: String
    
    @ObservedObject private var publisher: MetricPub
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    init(
        title: String,
        unit: String,
        dataType: MetricMeasurement.DataType,
        timerInterval: TimeInterval
    ) {
        
        self.title = title
        self.unit = unit
        self.publisher = MetricPub(
            appDatabase: AppDatabase.shared,
            dataType: dataType,
            rowLimit: 1,
            timerInterval: timerInterval
        )
        self.publisher.refresh()
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
        .onLoad() {
            setRefresh(facebit.state)
            publisher.refresh()
        }
        .onAppear() { setRefresh(facebit.state) }
        .onDisappear() { publisher.stop() }
        .onReceive(facebit.$state.dropFirst()) { state in
            setRefresh(state)
        }
    }
    
    func setRefresh(_ state: PeripheralState) {
        if state == .connected {
            publisher.start()
        } else {
            publisher.stop()
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
