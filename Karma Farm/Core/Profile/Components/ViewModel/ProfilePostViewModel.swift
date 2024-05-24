//
//  ProfilePostFilterViewModel.swift
//  Karma Farm
//
import Foundation

enum ProfilePostFilterViewModel: Int, CaseIterable, Identifiable {
    case posts
    case replies
    
    var title: String {
        switch self {
        case .posts: return "Posts"
        case .replies: return "Replies"
        }
    }
    
    var id: Int { return self.rawValue }
}
