//
//  MyFaceBitMainView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/19/21.
//

import SwiftUI
import Combine
import ACarousel

struct MyFaceBitMainViewMacOS: View {
    @EnvironmentObject var facebit: FaceBitPeripheral
    
    var cards: [FaceBitNotificationCard] = []

    var body: some View {
        NavigationView {
            VStack {
                FaceBitStatusView()
                    .padding()
                
                FaceBitNotificationView(cards: cards)
                    .frame(height: 100.0)
                
                Divider()

                MyFaceBitMetricsDashboardView()
                
                Spacer()
            }
            .onAppear(perform: searchForFaceBit)
            .navigationBarTitle("My FaceBit", displayMode: .inline)
            .navigationBarItems(trailing:
                FaceBitConnectionStatusButtonView()
            )

            Spacer()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func searchForFaceBit() {
        if facebit.state != .connected {
            print("searching")
            BluetoothConnectionManager
                .shared
                .searchFor(peripheral: facebit)
        }
    }
}

struct MyFaceBitMainViewMacOS_Previews: PreviewProvider {
    static var previews: some View {
        MyFaceBitMainViewMacOS()
    }
}
