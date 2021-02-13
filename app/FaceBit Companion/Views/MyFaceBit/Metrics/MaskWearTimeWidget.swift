//
//  MaskWearTimeWidget.swift
//  FaceBit Companion
//
//  Created by blaine on 2/12/21.
//

import SwiftUI

struct MaskWearTimeWidget: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    @State private var showModal: Bool = false
    
    var timeString: String {
        return "00:00:00"
    }
    
    var body: some View {
        Button(
            action: { showModal = true },
            label: {
                WidgetView(content: {
                    VStack {
                        Text("Wear Time")
                            .bold()
                        Spacer()
                        Text(timeString)
                            .font(.system(size: 28.0))
                        Spacer()
                    }
                })
            }
        )
        .sheet(
            isPresented: $showModal,
            onDismiss: nil,
            content: {
                PrimaryButton(action: {}, content: { Text("Dispose Mask") })
            }
        )
    }
}

struct MaskWearTimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        MaskWearTimeWidget()
    }
}
