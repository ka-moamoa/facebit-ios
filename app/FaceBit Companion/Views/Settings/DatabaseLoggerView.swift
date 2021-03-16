//
//  DatabaseLoggerView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

import SwiftUI

struct DatabaseLoggerView: View {
    @ObservedObject var viewModel: DataLoggerViewModel
    
    var body: some View {
        if let read = viewModel.dataReads.first {
            Text("\(read.startTime)")
        }
    }
}

struct DatabaseLoggerView_Previews: PreviewProvider {
    static var previews: some View {
        DatabaseLoggerView(
            viewModel: DataLoggerViewModel(
                appDatabase: AppDatabase.shared,
                facebit: FaceBitPeripheral(readChars: [])
            )
        )
    }
}
