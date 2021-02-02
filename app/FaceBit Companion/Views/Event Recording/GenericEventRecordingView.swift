//
//  GenericEventRecordingView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/28/21.
//

import SwiftUI

struct GenericEventRecordingView: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    var body: some View {
        if facebit.state != PeripheralState.connected {
            Text("Please Connect Facebit Device")
                .navigationTitle("Event Recording")
                .navigationBarItems(trailing:
                    FaceBitConnectionStatusButtonView()
                )
        } else {
            VStack {
                Text("Event Recording")
                    .font(.headline)
                Spacer()
                EventFormView()
            }
            .padding()
            .navigationTitle("Event Recording")
            .navigationBarItems(trailing:
                FaceBitConnectionStatusButtonView()
            )
        }
        
    }
}

struct GenericEventRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        GenericEventRecordingView()
    }
}
