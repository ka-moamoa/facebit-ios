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
    @EnvironmentObject var maskVM: MaskViewModel
    
    @State var cards: [FaceBitNotificationCard] = []

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    NavigationLink(
                        destination: FaceBitDetailsView(),
                        label: {
                            FaceBitStatusView()
                                .padding()
                        })
                    
                    if cards.count > 0 {
                        FaceBitNotificationView(cards: cards)
                            .frame(height: 100.0)
                    }
                }
                
                MyFaceBitMetricsDashboardView()
                    .background(Color("PrimaryWhite"))
                
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
        .accentColor(Color("PrimaryPurple"))
        .onReceive(maskVM.$mask, perform: { mask in
            guard let mask = mask else { return }
            
            if mask.percentValue >= 0.75 {
                cards.append(
                    FaceBitNotificationCard(
                        title: "About time to Replace Your Mask",
                        message: "Your mask is nearing the end of its suggested wear time. You should consider replacing it soon",
                        notificationType: .alert
                    )
                )
            } else if mask.percentValue >= 0.01 {
                cards.append(
                    FaceBitNotificationCard(
                        title: "Time to Replace Mask",
                        message: "Your mask is at the end of it's suggest wear time. Replace to ensure quality of protection.",
                        notificationType: .warning
                    )
                )
            }
        })
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
