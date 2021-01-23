//
//  ContentView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/12/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var facebit: FaceBitPeripheral
    
    var body: some View {
        TabView {
            MyFaceBitMainViewMacOS()
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
    
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FaceBitPeripheral())
    }
}
