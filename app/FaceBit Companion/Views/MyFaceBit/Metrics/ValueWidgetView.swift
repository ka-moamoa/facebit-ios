//
//  ValueWidgetView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct ValueWidgetView: View {
    @State var title: String
    @State var unit: String
    @Binding var value: Double
    
    var body: some View {
        WidgetView {
            VStack {
                Text(title)
                    .bold()
                Text("\(String(format: "%.2f", value))")
                    .font(.system(size: 48.0))
                Text(unit)
            }
        }
    }
}

struct ValueWidgetView_Previews: PreviewProvider {
    @State static var value: Double = 123.04
    
    static var previews: some View {
        ValueWidgetView(title: "Metric", unit: "coins", value: $value)
    }
}
