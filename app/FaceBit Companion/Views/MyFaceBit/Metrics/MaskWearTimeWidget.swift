//
//  MaskWearTimeWidget.swift
//  FaceBit Companion
//
//  Created by blaine on 2/12/21.
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

struct MaskWearTimeWidget: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    @EnvironmentObject var maskVM: MaskViewModel
    
    @State private var showModal: Bool = false
    
    var body: some View {
        Button(
            action: { showModal = true },
            label: {
                WidgetView(content: {
                    VStack {
                        Text("Wear Time")
                            .bold()
                        Spacer()
                        Text(maskVM.mask?.wearTimeString ?? "00:00:00")
                            .font(.system(size: 32.0))
                        ProgressBar(
                            value: maskVM.mask?.percentValue ?? 0.0,
                            backgroundColor: Color("PrimaryWhite"),
                            progressColor: Color("PrimaryOrange")
                        )
                        .frame(height: 25.0)
                        Spacer()
                    }
                })
            }
        )
        .sheet(
            isPresented: $showModal,
            onDismiss: nil,
            content: {
                VStack {
                    HStack {
                        Spacer()
                        Text("Mask Wear Time")
                            .font(.title)
                            .padding(16)
                        Spacer()
                    }
                    Divider()
                    MaskWearTimeView()
                    Spacer()
                    
                }
            }
        )
    }
}

struct MaskWearTimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        MaskWearTimeWidget()
    }
}
