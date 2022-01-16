//
//  ContentView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/12/21.
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

struct ContentView: View {
    @EnvironmentObject private var facebit: FaceBitPeripheral
    
    var body: some View {
        TabView {
            MyFaceBitMainViewMacOS(facebit: facebit, viewModel: MyFaceBitViewModel())
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("My FaceBit")
                }
            
            Text("My Insights")
                .font(.headline)
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Insights")
                }
            
            SettingsView()
                .font(.headline)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .accentColor(Color("PrimaryPurple"))
    
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FaceBitPeripheral(readChars: []))
    }
}
