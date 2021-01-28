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
                    Button(action: {
                        shareDatabase()
                    }, label: {
                        GenericSettingsRow(text: "Share SQLite Database")
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
    
    private func shareDatabase() {
        guard let data = SQLiteDatabase.dbPath else { return }
        let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
