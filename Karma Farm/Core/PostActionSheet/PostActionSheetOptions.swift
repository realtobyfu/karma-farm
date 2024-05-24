//
//  PostActionSheetOptions.swift
//  Karma Farm
//
//  Created by Tobias Fu on 1/27/24.
//

import Foundation

enum PostActionSheetOptions {
    case mute
    case hide
    case report
    case block
    
    var title: String {
        switch self {
        case .mute:
            return "Mute"
        case .hide:
            return "Hide"
        case .report:
            return "Report"
        case .block:
            return "Block"
        }
    }
}

