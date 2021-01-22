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
    @ObservedObject var facebit: FaceBitPeripheral
    
    var cards: [FaceBitNotificationCard] = [
        FaceBitNotificationCard(title: "hello", message: String.loremipsum()),
        FaceBitNotificationCard(title: "hello1", message: String.loremipsum()),
        FaceBitNotificationCard(title: "hello2", message: String.loremipsum()),
        FaceBitNotificationCard(title: "hello3", message: String.loremipsum()),
    ]

    var body: some View {
        NavigationView {
            VStack {
                FaceBitStatusView(facebit: facebit)
                    .padding()
                FaceBitNotificationView(cards: cards)
                    .frame(height: 100.0)
                Divider()
                Spacer()
            }
            .onAppear(perform: searchForFaceBit)
            .navigationBarTitle("My FaceBit", displayMode: .inline)
            .navigationBarItems(trailing:
                FaceBitConnectionStatusButtonView(facebit: facebit)
            )

            Spacer()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func searchForFaceBit() {
        print("searching")
        BluetoothConnectionManager
            .shared
            .searchFor(peripheral: facebit)
    }
}

struct MyFaceBitMainViewMacOS_Previews: PreviewProvider {
    static var previews: some View {
        MyFaceBitMainViewMacOS(facebit: FaceBitPeripheral())
    }
}
