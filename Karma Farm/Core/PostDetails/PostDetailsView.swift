//
//  ThreadDetailsView.swift
//  Threads
//
//

import SwiftUI

struct PostDetailsView: View {
    @State private var showReplySheet = false
    @StateObject var viewModel: PostDetailsViewModel
    
    private var post: Post {
        return viewModel.post
    }
    
    init(post: Post) {
        self._viewModel = StateObject(wrappedValue: PostDetailsViewModel(post: post))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    CircularProfileImageView(user: post.user, size: .small)
                    
                    Text(post.user?.username ?? "")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("12m")
                        .font(.caption)
                        .foregroundStyle(Color(.systemGray3))
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color(.darkGray))
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(post.caption)
                        .font(.subheadline)
                    
                    ContentActionButtonView(viewModel: ContentActionButtonViewModel(contentType: .post(post)))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider()
                .padding(.vertical)
            
            LazyVStack(spacing: 16) {
                ForEach(viewModel.replies) { reply in
                    PostCell(config: .reply(reply))
                }
            }
        }
        .sheet(isPresented: $showReplySheet, content: {
            PostReplyView(post: post)
        })
        .padding()
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PostDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailsView(post: dev.post)
    }
}
