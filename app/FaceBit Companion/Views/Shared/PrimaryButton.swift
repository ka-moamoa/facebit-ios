//
//  PrimaryButton.swift
//  FaceBit Companion
//
//  Created by blaine on 2/12/21.
//

import SwiftUI

struct PrimaryButton<Content: View>: View {
    let content: Content
    let action: ()->()
    
    init(action: @escaping ()->(), content: @escaping () -> Content) {
        self.content = content()
        self.action = action
    }
    
    var body: some View {
        Button(
            action: { action() },
            label: {
                content
                    .foregroundColor(Color("PrimaryWhite"))
                    .padding(16.0)
            }
        )
            .frame(height: 50.0)
            .background(
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(Color("PrimaryBrown"))
            )
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(action: {}, content: { Text("What is up") })
    }
}
