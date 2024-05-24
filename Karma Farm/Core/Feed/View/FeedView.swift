//
//  FeedView.swift
//  Threads
//
//  Created by Tobias Fu on 1/5/24.
//

import SwiftUI

struct FeedView: View {

    @StateObject var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack{
                    ForEach(viewModel.posts) {post in
                        PostCell(config: .post(post))
                    }
                }
            }
            .refreshable {
                Task { try await viewModel.fetchPosts() }
            }
            .navigationTitle("Karma Posts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {

                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

#Preview {
    FeedView()
}
