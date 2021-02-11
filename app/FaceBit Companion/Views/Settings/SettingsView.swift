//
//  SettingsView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Development")) {
                    NavigationLink(
                        destination: GenericEventRecordingView(),
                        label: {
                            GenericSettingsRow(text: "Record Events")
                        })
                    ShareDatabaseButtonView()
                    PurgeDatabaseButtonView()
                    Button(action: {
                        let rc = RespitoryClassifierPub(timeOffset: 4)
                        rc.fetchData()
                    }, label: {
                        Text("Test Classification")
                            .padding()
                    })
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing:
                FaceBitConnectionStatusButtonView()
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
