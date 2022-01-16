//
//  DataTableListView.swift
//  FaceBit Companion
//
//  Created by blaine on 3/16/21.
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
import GRDB
import SwiftUIRefresh

struct DataListView<T: FetchableRecord & MutablePersistableRecord & Identifiable & Codable, RowView: View>: View {
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
            .onDelete(perform: { indexSet in
                deleteItem(at: indexSet)
            })
        }
        .pullToRefresh(isShowing: $isLoading, onRefresh: {
            viewModel.refresh(callback: { isLoading = false })
        })
        .navigationTitle(title)
        .toolbar {
            Button("Export") {
                viewModel.saveAndShare(fileName: "data")
            }
            #if targetEnvironment(macCatalyst)
            Button("Refresh") {
                isLoading = true
                viewModel.refresh(callback: { isLoading = false })
            }
            #endif
            EditButton()
        }
        .onAppear() {
            isLoading = true
            viewModel.refresh(callback: { isLoading = false })
        }
    }
    
    
    private func deleteItem(at indexSet: IndexSet) {
        isLoading = true
        for idx in indexSet {
            viewModel.delete(at: idx)
        }
        viewModel.refresh(callback: { self.isLoading = false })
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
