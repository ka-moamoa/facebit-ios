//
//  GenericEventRecordingView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/28/21.
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

struct GenericEventRecordingView: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    @State private var activeEvent: Event?
    @State private var initialized: Bool = false
    
    var body: some View {
        VStack {
            if initialized {
                if activeEvent != nil {
                    ActiveEventView(activeEvent: $activeEvent)
                } else {
                    StartEventView(activeEvent: $activeEvent)
                }
            }else {
                Text("Checking for Active Event ...")
            }
        }
        .padding()
        .navigationTitle("Event Recording")
        .navigationBarItems(trailing:
            FaceBitConnectionStatusButtonView()
        )
        .onAppear(perform: {
            initialized = false
            do {
                self.activeEvent = try Event.activeEvent()
                self.initialized = true
            } catch {
                PersistanceLogger.error("Unable to load event: \(error.localizedDescription)")
            }
        })
    }
}

struct GenericEventRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        GenericEventRecordingView()
    }
}
