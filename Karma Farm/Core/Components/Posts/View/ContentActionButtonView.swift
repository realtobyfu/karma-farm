//
//  ContentActionButtonView.swift
//  Threads
//
//  Created by Tobias Fu on 1/23/24.
//

import SwiftUI

struct ContentActionButtonView: View {
    
    @ObservedObject var viewModel: ContentActionButtonViewModel
    @State private var showReplySheet = false

//    init(post: Post) {
//        self.viewModel = ContentActionButtonViewModel(contentType: post)
//    }
    
    private var didLike: Bool {
        return viewModel.post?.didLike ?? false
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 16) {
                Button {
                    handleLikeTapped()
                } label: {
                    Image(systemName: didLike ? "heart.fill" : "heart")
                        .foregroundColor(didLike ? .red : Color.theme.primaryText)
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "bubble.right")
                }
                Button {
                    
                } label: {
                    Image(systemName: "arrow.rectanglepath")
                }
                Button {
                    
                } label: {
                    Image(systemName: "paperplane")
                }
            }
            .foregroundColor(Color.theme.primaryText)
            HStack(spacing: 4) {
                if let post = viewModel.post {
                    if post.likes > 0 {
                        Text("\(post.likes) likes")
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // helper function for like/unlike
    private func handleLikeTapped() {
        Task {
            if didLike {
                try await viewModel.unlikePost()
            } else {
                try await viewModel.likePost()
            }
        }
    }
}

//
//struct ContentActionButtonsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentActionButtonView(viewModel: dev.post)
//    }
//}
