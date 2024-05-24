////
////  PostActionSheetView.swift
////  Karma Farm
////
////  Created by Tobias Fu on 1/27/24.
////
//
import SwiftUI

struct PostActionSheetView: View {
    let post: Post
    @State private var height: CGFloat = 168 // Adjusted height without follow/unfollow option
    @Binding var selectedAction: PostActionSheetOptions?
    
    var body: some View {
        List {
            Section {
                PostActionSheetRowView(option: .mute, selectedAction: $selectedAction)
            }
            
            Section {
                PostActionSheetRowView(option: .report, selectedAction: $selectedAction)
                    .foregroundColor(.red)
                
                PostActionSheetRowView(option: .block, selectedAction: $selectedAction)
                    .foregroundColor(.red)
            }
        }
        .presentationDetents([.height(height)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(12)
        .font(.footnote)
    }
}

struct PostActionSheetRowView: View {
    let option: PostActionSheetOptions
    @Environment(\.dismiss) var dismiss
    @Binding var selectedAction: PostActionSheetOptions?
    
    var body: some View {
        HStack {
            Text(option.title)
                .font(.footnote)
            
            Spacer()
        }
        .background(Color.theme.primaryBackground)
        .onTapGesture {
            selectedAction = option
            dismiss()
        }
    }
}
