//
//  RespiratoryClsWidgetView.swift
//  FaceBit Companion
//
//  Created by blaine on 2/11/21.
//

import SwiftUI

struct RespiratoryClsWidgetView: View {
    @ObservedObject private var publisher: RespitoryClassifierViewModel
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    init(timeOffset: TimeInterval=5, timerInterval: TimeInterval = 25) {
        self.publisher = RespitoryClassifierViewModel(
            appDatabase: AppDatabase.shared,
            timeOffset: timeOffset
        )
    }
    
    var body: some View {
        WidgetView {
            VStack {
                Text("Resp. Class.")
                    .bold()
                Spacer()
                Text(publisher.classification.label)
                    .font(.system(size: 32.0))
                Spacer()
            }
        }
    }
}

struct RespiratoryClsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        RespiratoryClsWidgetView()
    }
}
