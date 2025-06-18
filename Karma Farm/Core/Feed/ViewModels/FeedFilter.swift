//
//  FeedFilter.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//


import Foundation

enum FeedFilter: String, CaseIterable {
    case all = "All"
    case following = "Following"
    case trending = "Trending"
    case myPosts = "My Posts"
    
    var title: String {
        return self.rawValue
    }
}
