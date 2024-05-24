//
//   EditProfileView.swift
//  Threads
//
//  Created by Tobias Fu on 1/7/24.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    @State private var isPrivateProfile = false
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    private var user: User? {
        return viewModel.currentUser
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    // this makes sure the stack on the top is still white
                    .edgesIgnoringSafeArea([.bottom, .horizontal])
                
                VStack {
                    // name and profile image
                    HStack {
                        VStack (alignment: .leading) {
                            Text("Name")
                                .fontWeight(.semibold)
                             
                            Text(user?.fullname ?? "")
                        }
//
                        Spacer()
                        
                        PhotosPicker(selection: $viewModel.selectedImage) {
                            if let image = viewModel.profileImage {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: ProfileImageSize.small.dimension, height: ProfileImageSize.small.dimension)
                                    .clipShape(Circle())
                                    .foregroundColor(Color(.systemGray4))
                            } else {
                                CircularProfileImageView(user: user, size: .small)
                            }
                        }
                    }
                    
                    Divider()
                    //bio field
                    
                    VStack(alignment: .leading) {
                        Text("Bio")
                            .fontWeight(.semibold)
                        TextField("Enter your bio...", text:  $viewModel.bio, axis: .vertical)
                    }
                    .font(.footnote)
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Link")
                            .fontWeight(.semibold)
                        TextField("Add link ...", text:  $viewModel.bio, axis: .vertical)
                    }
                    
                    Divider()
                    
                    Toggle("Private profile", isOn: $isPrivateProfile)
                }
                .font(.footnote)
                .padding()
                .background(.white)
                .cornerRadius(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                }
                .padding()

            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
                        
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        Task {
                            try await viewModel.updateUserData()
                                dismiss()  
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                }
            }
        }
    }
}


//#Preview {
//    EditProfileView(user: dev.user)
//}
