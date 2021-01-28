//
//  FaceBitNotificationView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI
import ACarousel

struct FaceBitNotificationView: View {
    @State var cards: [FaceBitNotificationCard] = []
    @State var height: CGFloat = 100.0
    
    var body: some View {
        if cards.count > 0 {
            ACarousel(
                cards,
                sidesScaling: 1.0) { card in
                FaceBitNotificationCardView(card: card, height: height - 16.0)
            }
        } else {
            Text("No new notifications")
        }
    }
}

struct FaceBitNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        FaceBitNotificationView(cards: [
            FaceBitNotificationCard(title: "hello", message: "Hello"),
            FaceBitNotificationCard(title: "hello1", message: "Hello1"),
            FaceBitNotificationCard(title: "hello2", message: "Hello2"),
            FaceBitNotificationCard(title: "hello3", message: "Hello3"),
        ])
    }
}
