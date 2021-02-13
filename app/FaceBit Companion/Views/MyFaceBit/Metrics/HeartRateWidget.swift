//
//  HeartRateWidget.swift
//  FaceBit Companion
//
//  Created by blaine on 2/13/21.
//

import SwiftUI

struct HeartRateWidget: View {
    @State var heartRate: Float
    @State var readTime: Date
    @State var samplesLast24: Int
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }
    
    var body: some View {
        WidgetView {
            VStack {
                Text("Heart Rate")
                    .bold()
//                Spacer()
//                Text("\(String(format: "%.2f", heartRate))")
//                    .font(.system(size: 28.0))
//                Spacer()
//                
//                Text("Recorded: \(dateFormatter.string(from: readTime))")
//                        .font(.system(size: 12.0))
//                    
//                Text("\(samplesLast24) in last 24h")
//                    .font(.system(size: 12.0))
                
            }
        }
    }
}

struct HeartRateWidget_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateWidget(heartRate: 54.7, readTime: Date(), samplesLast24: 15)
    }
}
