//
//  PostCell.swift
//  Threads
//
//  Created by Tobias Fu on 1/6/24.
//

import SwiftUI

enum PostViewConfig {
    case post(Post)
    case reply(PostReply)
}


struct PostCell: View {
    let config: PostViewConfig
    @State private var showPostActionSheet = false
    @State private var selectedPostAction: PostActionSheetOptions?
    
    
    private var user: User? {
        switch config {
        case .post(let post):
            return post.user
        case .reply(let postReply):
            return postReply.replyUser
        }
    }
    
    private var caption: String {
        switch config {
        case .post(let post):
            return post.caption
        case .reply(let postReply):
            return postReply.replyText
        }
    }
    
    private var timestampString: String {
        switch config {
        case .post(let post):
            return post.createdAt.timestampString()
        case .reply(let postReply):
            return postReply.createdAt.timestampString()
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                CircularProfileImageView(user: user, size: .medium)
                
                VStack (alignment: .leading, spacing: 4) {
                    HStack {
                        Text(user?.username ?? "")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        Spacer()
                        
                        Text(timestampString)
                            .font(.caption)
                            .foregroundColor(Color(.systemGray3))
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(Color(.darkGray))
                        }
                    }
                    Text(caption)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                    
                    ContentActionButtonView(viewModel: ContentActionButtonViewModel(contentType: config))
                        .padding(.top, 12)
                 }
            }
//            .sheet(isPresented: $showPostActionSheet) {
//                if case .post(let post) = config {
//                    PostActionSheetView(post: post, selectedAction: $showPostActionSheet)
//                }
//            }

            Divider()
        }
        .onChange(of: selectedPostAction, perform: { newValue in
            switch newValue {
            case .block:
                print("DEBUG: Block user here..")
            case .hide:
                print("DEBUG: Hide thread here..")
            case .mute:
                print("DEBUG: Mute threads here..")
//            case .unfollow:
//                print("DEBUG: Unfollow here..")
            case .report:
                print("DEBUG: Report thread here..")
            case .none:
                break
            }
        })
        .foregroundColor(Color.theme.primaryText)
    }
}

struct FeedCell_Previews: PreviewProvider {
    static var previews: some View {
        PostCell(config: .post(dev.post))
    }
}
