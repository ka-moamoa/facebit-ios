//
//  FaceBitNotificationView.swift
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
