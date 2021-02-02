//
//  GenericEventRecordingView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/28/21.
//

import SwiftUI

struct GenericEventRecordingView: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    @State private var activeEvent: SmartPPEEvent? = SmartPPEEvent.getActiveEvent()
    
    var body: some View {
        VStack {
            if activeEvent != nil {
                ActiveEventView(activeEvent: $activeEvent)
            } else {
                StartEventView(activeEvent: $activeEvent)
            }
        }
        .padding()
        .navigationTitle("Event Recording")
        .navigationBarItems(trailing:
            FaceBitConnectionStatusButtonView()
        )
        .onAppear(perform: {
            activeEvent = SmartPPEEvent.getActiveEvent()
        })
    }
}

struct GenericEventRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        GenericEventRecordingView()
    }
}
