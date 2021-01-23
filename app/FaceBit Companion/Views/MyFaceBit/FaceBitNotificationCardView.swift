//
//  FaceBitNotificationCardView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

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
            Spacer()
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
