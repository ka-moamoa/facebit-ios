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
        VStack {
            Text("Event Recording")
                .font(.headline)
            Spacer()
            EventFormView()
        }
        .padding()
    }
}

struct GenericEventRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        GenericEventRecordingView()
    }
}
