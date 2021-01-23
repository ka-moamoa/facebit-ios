//
//  WidgetView.swift
//  FaceBit Companion
//
//  Created by blaine on 1/22/21.
//

import SwiftUI

struct WidgetView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            content
                .padding()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(lineWidth: 1.0)
                )
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
