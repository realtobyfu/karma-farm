//
//  PostReplyView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 1/27/24.
//

import SwiftUI

struct PostReplyView: View {
    let post: Post
    @State private var replyText = ""
    @State private var postViewSize: CGFloat = 24
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = PostReplyViewModel()
    
    private var currentUser: User? {
        return UserService.shared.currentUser
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    HStack(alignment: .top) {
                        VStack {
                            CircularProfileImageView(user: post.user, size: .small)

                            Rectangle()
                                .frame(width: 2, height: postViewSize - 24)
                                .foregroundColor(Color(.systemGray4))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(post.user?.username ?? "")
                                .fontWeight(.semibold)
                            
                            Text(post.caption)
                                .multilineTextAlignment(.leading)
                        }
                        .font(.footnote)
                        
                        Spacer()
                    }
                    
                    HStack(alignment: .top) {
                        CircularProfileImageView(user: currentUser, size: .small)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentUser?.username ?? "")
                                .fontWeight(.semibold)
                            
                            TextField("Add your reply...", text: $replyText, axis: .vertical)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .font(.footnote)
                        
                        Spacer()
                        
                        if !replyText.isEmpty {
                            Button {
                                replyText = ""
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Spacer()
                    
                }
                .padding()
                .navigationTitle("Reply")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.theme.primaryText)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Post") {
                            Task {
                                try await viewModel.uploadPostReply(toPost: post, replyText: replyText)
                                dismiss()
                            }
                        }
                        .opacity(replyText.isEmpty ? 0.5 : 1.0)
                        .disabled(replyText.isEmpty)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.theme.primaryText)
                    }
                }
            }
        }
        .onAppear { setPostViewHeight() }
    }
    
    func setPostViewHeight() {
        let imageHeight: CGFloat = 40
        let captionSize = post.caption.sizeUsingFont(usingFont: UIFont.systemFont(ofSize: 12))
        
        self.postViewSize = captionSize.height + imageHeight
    }
}

struct PostReplyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PostReplyView(post: dev.post)
        }
    }
}
