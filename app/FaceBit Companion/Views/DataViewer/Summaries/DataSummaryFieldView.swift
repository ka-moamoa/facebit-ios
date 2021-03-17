//
//  DataSummaryFieldView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import SwiftUI

struct DataSummaryFieldView: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text("\(title): ")
                .bold()
            Text(value)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.body)
        }
    }
}

struct DataSummaryFieldView_Previews: PreviewProvider {
    static var previews: some View {
        DataSummaryFieldView(title: "Title", value: "\(1.23)")
    }
}
