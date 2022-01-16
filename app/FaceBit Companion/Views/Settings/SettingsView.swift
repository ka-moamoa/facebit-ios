//
//  SettingsView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
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

struct SettingsView: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Events")) {
                    NavigationLink(
                        destination: GenericEventRecordingView(),
                        label: {
                            GenericSettingsRow(text: "Record Events")
                        }
                    )
                }
                
                Section(header: Text("Local Database")) {
                    NavigationLink(
                        destination: DatabaseViewerView(viewModel: DataViewerViewModel(appDatabase: AppDatabase.shared, facebit: facebit)),
                        label: {
                            GenericSettingsRow(text: "Data Viewer")
                        }
                    )
                    ShareDatabaseButtonView()
                }
                
                Section(header: Text("Development")) {
                    Button(action: {
                        let rc = RespitoryClassifierViewModel(
                            appDatabase: AppDatabase.shared,
                            timeOffset: 4
                        )
                    }, label: {
                        Text("Test Classification")
                            .padding()
                    })
                }
                Section(header: Text("Danger Zone")) {
                    PurgeDatabaseButtonView()
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
