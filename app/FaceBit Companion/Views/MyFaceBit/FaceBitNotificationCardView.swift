//
//  FaceBitNotificationCardView.swift
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

struct FaceBitNotificationCard: Identifiable {
    enum NotificationType {
        case alert
        case warning
        case success
        case info
        
        var image: some View {
            switch self {
            case .alert:
                return Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            case .warning:
                return Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
            case .success:
                return Image(systemName: "info.circle.fill")
                    .foregroundColor(.green)
            case .info:
                return Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
            }
        }
    }
    
    let id = UUID()
    var title: String
    var message: String
    var notificationType: NotificationType = .info
    
}

struct FaceBitNotificationCardView: View, Identifiable {
    @State var card: FaceBitNotificationCard
    
    @State var width: CGFloat = UIScreen.main.bounds.width - 32.0
    @State var height: CGFloat = 100
    
    let id = UUID()
    
    var body: some View {
        VStack(spacing: 8.0) {
            HStack {
                card.notificationType.image
                    .font(.system(size: 18.0))
                Text(card.title)
                    .font(.system(size: 16))
                Spacer()
            }
            Text(card.message)
                .font(.system(size: 14.0))
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10.0)
                .stroke(Color.gray, lineWidth: 2)
        )
    }
}

struct FaceBitNotificationCardView_Previews: PreviewProvider {
    static var previews: some View {
        FaceBitNotificationCardView(
        card: FaceBitNotificationCard(
            title: "Alert!",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.",
            notificationType: .info
            )
        )
    }
}
