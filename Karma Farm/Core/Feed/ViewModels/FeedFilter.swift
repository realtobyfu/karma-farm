//
//  FeedFilter.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import Foundation

enum FeedFilter: String, CaseIterable {
    case all = "all"
    case requests = "requests"
    case offers = "offers"
    case nearby = "nearby"
    case following = "following"
    case myPosts = "my_posts"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .requests: return "Requests"
        case .offers: return "Offers"
        case .nearby: return "Nearby"
        case .following: return "Following"
        case .myPosts: return "My Posts"
        }
    }
}
