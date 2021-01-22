//
//  SettingsView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var facebit: FaceBitPeripheral
    
    var body: some View {
        NavigationView {
            List {
//                Section(header: Text("General")) {
//                    KeyValueRow(key: "Application Version", value: Bundle.main.versionNumber)
//                    KeyValueRow(key: "Application Build", value: Bundle.main.buildNumber)
//                }
                
                Section(header: Text("Development")) {
                    NavigationLink(
                        destination: EventRecorderView(facebit: facebit),
                        label: {
                            GenericSettingsRow(text: "Record Events")
                        })
                    
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(facebit: FaceBitPeripheral())
    }
}
