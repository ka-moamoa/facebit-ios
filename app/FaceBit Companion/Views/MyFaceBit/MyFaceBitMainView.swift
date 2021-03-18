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
    @ObservedObject var viewModel: MyFaceBitViewModel

    //    @EnvironmentObject var facebit: FaceBitPeripheral
//    @EnvironmentObject var maskVM: MaskViewModel
    
    @State var cards: [FaceBitNotificationCard] = []

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    NavigationLink(
                        destination: FaceBitDetailsView(
                            facebit: facebit,
                            bleManager: BluetoothConnectionManager.shared,
                            viewModel: FaceBitDetailsViewModel(appDatabase: AppDatabase.shared)
                        ),
                        label: {
                            FaceBitStatusView()
                                .padding()
                        })
                    
                    if cards.count > 0 {
                        FaceBitNotificationView(cards: cards)
                            .frame(height: 100.0)
                    }
                }
                
                MyFaceBitMetricsDashboardView(
                    facebit: facebit,
                    maskVM: MaskViewModel(db: AppDatabase.shared)
                )
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
        MyFaceBitMainViewMacOS(
            facebit: FaceBitPeripheral(readChars: []), viewModel: MyFaceBitViewModel())
    }
}
