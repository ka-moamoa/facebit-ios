//
//  DataTableListView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
//

import SwiftUI
import GRDB
import SwiftUIRefresh

struct DataListView<T: FetchableRecord & Identifiable & Codable, RowView: View>: View {
    @ObservedObject var viewModel: DatabaseTableViewModel<T>
    var buildRow: (T) -> RowView
    var title: String
    
    @State private var isLoading: Bool = false
    
    init(viewModel: DatabaseTableViewModel<T>, rowBuilder: @escaping (T) -> RowView, title:String) {
        self.viewModel = viewModel
        self.buildRow = rowBuilder
        self.title = title
    }
    
    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                buildRow(item)
            }
        }
        .pullToRefresh(isShowing: $isLoading, onRefresh: {
            viewModel.refresh(callback: { isLoading = false })
        })
        .navigationTitle(title)
        .toolbar {
            Button("Export") {
                viewModel.saveAndShare(fileName: "data")
            }
        }
    }
}

struct DataTableListView_Previews: PreviewProvider {
    static var previews: some View {
        DataListView(
            viewModel: DatabaseTableViewModel(
                appDatabase: AppDatabase.shared,
                request: Timestamp.order(Column("id").desc)),
            rowBuilder: { ts in
                TimestampSummaryView(timestamp: ts)
            },
            title: "test"
        )
    }
}
