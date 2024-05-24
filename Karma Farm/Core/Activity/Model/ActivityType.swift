//
//  ActivityType.swift
//  Karma Farm
//
//  Created by Tobias Fu on 1/27/24.
//

import Foundation

enum ActivityType: Int, CaseIterable, Identifiable, Codable {
    case like
    case reply
    
    var id: Int { return self.rawValue }
}
