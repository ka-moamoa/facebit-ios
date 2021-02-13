//
//  WidgetView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct WidgetView<Content: View>: View {
    let content: Content
    
    @State private var showDetails: Bool = false
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            content
                .padding()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(Color("PrimaryPurple"))
                )
                .foregroundColor(Color("PrimaryWhite"))
        }
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView {
            Text("I am Widget")
        }
    }
}
