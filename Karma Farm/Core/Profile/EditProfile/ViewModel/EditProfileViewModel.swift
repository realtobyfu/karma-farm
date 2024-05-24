////
////  EditProfileViewModel.swift
////  Threads
////
////  Created by Tobias Fu on 1/11/24.
////
//
//import PhotosUI
//import SwiftUI
//
//class EditProfileViewModel: ObservableObject {
//    @Published var selectedItem: PhotosPickerItem? {
//        didSet { Task { await loadImage()  } }
//    }
//    
//    @Published var profileImage: Image?
//    
//    // this has to be an uiimage, so in "ImageUploader", we can generate jpegData
//    private var uiImage: UIImage?
//    
//    func updateUserData() async throws {
//        print("DEBUG: Update user data here.. ")
//    }
//    
//    @MainActor
//    // this returns a image from the selected item in PhotosUI
//    private func loadImage() async {
//        guard let item = selectedItem else { return }
//        
//        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
//        guard let uiImage = UIImage(data: data) else { return }
//        self.uiImage = uiImage
//        self.profileImage = Image(uiImage: uiImage)
//    }
//    
//    private func updateProfileImage() async throws {
//        guard let image = self.uiImage else { return }
//        guard let imageUrl = try? await ImageUploader.uploadImage(image) else { return }
//        try await  UserService.shared.updateUserProfileImage(withImageUrl: imageUrl)
//    }
//}
