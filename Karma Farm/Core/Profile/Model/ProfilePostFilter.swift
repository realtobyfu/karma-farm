//
//  ProfilePostFilter.swift
//  Threads
//
//  Created by Tobias Fu on 1/6/24.
//

import Foundation

enum ProfilePostFilter: Int, CaseIterable, Identifiable {
    case posts
    case completed
    
    var title: String {
        switch self {
            case .posts: return "Posts"
            case .completed: return "Completed"
        }
    }
    
    var id: Int { return self.rawValue }
}
