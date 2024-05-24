//
//  PostReplyCell.swift
//  Karma Farm
//
//  Created by Tobias Fu on 1/28/24.
//

import SwiftUI

struct PostReplyCell: View {
    let reply: PostReply
    @State private var postViewSize: CGFloat = 24
    @State private var showReplySheet = false
    
    private var post: Post? {
        return reply.post
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let post = post {
                HStack(alignment: .top) {
                    VStack {
                        CircularProfileImageView(user: post.user, size: .small)
                        
                        Rectangle()
                            .frame(width: 2, height: postViewSize - 24)
                            .foregroundColor(Color(.systemGray4))
                    }
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(post.user?.username ?? "")
                                .fontWeight(.semibold)
                            
                            Text(post.caption)
                            
                        }
                        .font(.footnote)
                        
                        ContentActionButtonView(viewModel: ContentActionButtonViewModel(contentType: .post(post)))
                            .padding(.bottom, 4)
                    }
                    
                    Spacer()
                }
            }
            
            HStack(alignment: .top) {
                CircularProfileImageView(user: reply.replyUser, size: .small)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(reply.replyUser?.username ?? "")
                        .fontWeight(.semibold)
                    
                    Text(reply.replyText)
                }
                .font(.footnote)

            }
            
            Divider()
        }
        .onAppear {
            setThreadHeight()
        }
    }
    
    func setThreadHeight() {
        guard let post = post else { return }
        let imageHeight: CGFloat = 40
        let captionHeight = post.caption.sizeUsingFont(usingFont: UIFont.systemFont(ofSize: 12))
        let actionButtonViewHeight: CGFloat = 40
        self.postViewSize = imageHeight + captionHeight.height + actionButtonViewHeight
    }
}

//struct PostReplyCell_Previews: PreviewProvider {
//    static var previews: some View {
//        PostReplyCell(reply: dev.reply)
//    }
//}
