import SwiftUI
import PhotosUI

struct PrivateProfileSetupView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var realName = ""
    @State private var age = ""
    @State private var selectedGender = "Prefer not to say"
    @State private var selectedPrivateImage: PhotosPickerItem?
    @State private var privateProfileImage: Image?
    
    private let genderOptions = ["Male", "Female", "Non-binary", "Other", "Prefer not to say"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        VStack(spacing: 8) {
                            Text("Private Profile")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("This information is only shared with people you choose to connect with")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        // Private Photo Section
                        VStack(spacing: 16) {
                            Text("Private Photo")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Share a more personal photo with your connections")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Spacer()
                                
                                PhotosPicker(selection: $selectedPrivateImage, matching: .images) {
                                    if let privateProfileImage = privateProfileImage {
                                        privateProfileImage
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.purple, lineWidth: 3)
                                            )
                                    } else {
                                        ZStack {
                                            Circle()
                                                .fill(Color(.systemGray5))
                                                .frame(width: 120, height: 120)
                                            
                                            VStack(spacing: 8) {
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.purple)
                                                
                                                Text("Add Photo")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.purple)
                                            }
                                        }
                                    }
                                }
                                .onChange(of: selectedPrivateImage) { newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                            privateProfileImage = Image(uiImage: uiImage)
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        
                        // Personal Information
                        VStack(spacing: 16) {
                            Text("Personal Information")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("Real Name (optional)", text: $realName)
                                .textFieldStyle(OnboardingTextFieldStyle())
                            
                            TextField("Age (optional)", text: $age)
                                .textFieldStyle(OnboardingTextFieldStyle())
                                .keyboardType(.numberPad)
                                .onChange(of: age) { newValue in
                                    // Only allow numbers
                                    age = newValue.filter { $0.isNumber }
                                }
                            
                            // Gender Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Gender (optional)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Menu {
                                    ForEach(genderOptions, id: \.self) { option in
                                        Button(option) {
                                            selectedGender = option
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedGender)
                                            .font(.system(size: 16))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Privacy Notice
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "shield.checkerboard")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                                
                                Text("Your Privacy is Protected")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                PrivacyPointView(
                                    icon: "eye.slash.fill",
                                    text: "Only visible to your connections"
                                )
                                
                                PrivacyPointView(
                                    icon: "lock.fill",
                                    text: "Never used for public profiles"
                                )
                                
                                PrivacyPointView(
                                    icon: "hand.raised.fill",
                                    text: "You control who sees this information"
                                )
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePrivateProfile()
                    }
                    .foregroundColor(.purple)
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    private func savePrivateProfile() {
        Task {
            // TODO: API call to save private profile
            dismiss()
        }
    }
}

struct PrivacyPointView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.green)
                .frame(width: 16)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    PrivateProfileSetupView()
} 