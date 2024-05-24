//
//  UserContentListView.swift
//  Threads
//
//  Created by Tobias Fu on 1/11/24.
//

import SwiftUI

import SwiftUI

struct UserContentListView: View {
    @Binding var selectedFilter: ProfilePostFilterViewModel
    @StateObject var viewModel: UserContentListViewModel
    @Namespace var animation
    
    init(selectedFilter: Binding<ProfilePostFilterViewModel>, user: User) {
        self._selectedFilter = selectedFilter
        self._viewModel = StateObject(wrappedValue: UserContentListViewModel(user: user))
    }
    
    var body: some View {
        VStack {
            HStack {
                ForEach(ProfilePostFilterViewModel.allCases) { option in
                    VStack {
                        Text(option.title)
                            .font(.subheadline)
                            .fontWeight(selectedFilter == option ? .semibold : .regular)
                        
                        if selectedFilter == option {
                            Rectangle()
                                .foregroundStyle(Color.theme.primaryText)
                                .frame(width: 180, height: 1)
                                .matchedGeometryEffect(id: "item", in: animation)
                        } else {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 180, height: 1)
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedFilter = option
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            
            LazyVStack {
                if selectedFilter == .posts {
                    if viewModel.posts.isEmpty {
                        Text(viewModel.noContentText(filter: .posts))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.posts) { post in
                            PostCell(config: .post(post))
                        }
                        .transition(.move(edge: .leading))
                    }
                } else {
                    if viewModel.replies.isEmpty {
                        Text(viewModel.noContentText(filter: .replies))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.replies) { reply in
                            PostReplyCell(reply: reply)
                        }
                        .transition(.move(edge: .trailing))
                    }
                }
            }
            
            .padding(.vertical, 8)
        }
    }
}

struct UserContentListView_Previews: PreviewProvider {
    static var previews: some View {
        UserContentListView(
            selectedFilter: .constant(.posts),
            user: dev.user
        )
    }
}
