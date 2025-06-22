//
//  PhoneAuthView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import FirebaseAuth
import SwiftUI
import FirebaseCore

struct CountryCode {
    let name: String
    let code: String
    let dialCode: String
    let flag: String
}

struct PhoneAuthView: View {
    @StateObject private var viewModel = PhoneAuthViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var verificationID: String?
    @State private var showVerificationField = false
    @State private var selectedCountry = CountryCode(name: "United States", code: "US", dialCode: "+1", flag: "🇺🇸")
    @State private var showCountryPicker = false
    @State private var isResendingCode = false
    @State private var resendTimer = 60
    @State private var canResend = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // Logo section - bigger logo (same as original)
            VStack(spacing: 32) {
                Spacer()
                
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Spacer()
            }
            .frame(maxHeight: .infinity)
            
            if !showVerificationField {
                // Phone input form section - compact like original
                VStack(spacing: 12) {
                    // Country code and phone number field
                    HStack(spacing: 0) {
                        // Country Picker Button
                        Button(action: { showCountryPicker = true }) {
                            HStack(spacing: 8) {
                                Text(selectedCountry.flag)
                                    .font(.system(size: 16))
                                Text(selectedCountry.dialCode)
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8, corners: [.topLeft, .bottomLeft])
                        }
                        .foregroundColor(.primary)
                        
                    // Phone Number Input
                        TextField("Phone Number", text: $phoneNumber)
                            .keyboardType(.numberPad)
                            .textContentType(.telephoneNumber)
                            .font(.system(size: 15))
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8, corners: [.topRight, .bottomRight])
                            .onChange(of: phoneNumber) { newValue in
                                phoneNumber = formatPhoneNumber(newValue)
                            }
                    }
                    
                    // Send Code button - purple like original
                    Button(action: sendVerificationCode) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("Send Verification Code")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isValidPhoneNumber ? Color.purple : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isValidPhoneNumber || authManager.isLoading)
                    .opacity(isValidPhoneNumber ? 1.0 : 0.6)
                    
                    // Error message
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                            .multilineTextAlignment(.center)
                    }
                    }
                .padding(.horizontal, 24)
                    
            } else {
                // Verification code form section - compact like original
                VStack(spacing: 12) {
                    // Info text
                    Text("Enter the 6-digit code sent to \(selectedCountry.dialCode) \(phoneNumber)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                    
                    // Verification Code Input
                        TextField("Verification Code", text: $verificationCode)
                            .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .onChange(of: verificationCode) { newValue in
                            if newValue.count > 6 {
                                verificationCode = String(newValue.prefix(6))
                            }
                            if verificationCode.count == 6 {
                            verifyCode()
                            }
                        }
                    
                    // Verify button - purple like original
                    Button(action: verifyCode) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("Verify Code")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(verificationCode.count == 6 ? Color.purple : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(verificationCode.count != 6 || authManager.isLoading)
                    .opacity(verificationCode.count == 6 ? 1.0 : 0.6)
                    
                    // Error message
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                }
                
                Spacer()
                
            // Bottom section like original
            VStack(spacing: 16) {
                Divider()
                
                if showVerificationField {
                    // Resend and back options
                    VStack(spacing: 8) {
                        if canResend {
                            Button("Resend Code") {
                                resendCode()
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .disabled(isResendingCode)
                        } else {
                            Text("Resend code in \(resendTimer)s")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Button("Change Phone Number") {
                            goBack()
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    }
                } else {
                    // Terms text like original signup flow
                Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                        .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    
                    // Debug button for testing
                    #if DEBUG
                    Button("🔧 Debug Firebase") {
                        Task {
                            await testFirebaseConfiguration()
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                    #endif
                }
            }
            .padding(.bottom, 34)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
        }
        .onReceive(timer) { _ in
            if showVerificationField && !canResend && resendTimer > 0 {
                resendTimer -= 1
                if resendTimer == 0 {
                    canResend = true
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isValidPhoneNumber: Bool {
        let cleanedNumber = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return cleanedNumber.count >= 10
    }
    
    // MARK: - Actions
    private func sendVerificationCode() {
        let fullPhoneNumber = selectedCountry.dialCode + phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        print("🔥 DEBUG: Attempting to send verification code to: \(fullPhoneNumber)")
        
        Task {
            do {
                print("🔥 DEBUG: Calling authManager.startPhoneVerification")
                verificationID = try await authManager.startPhoneVerification(phoneNumber: fullPhoneNumber)
                print("🔥 DEBUG: Successfully got verification ID: \(verificationID ?? "nil")")
                
                await MainActor.run {
                withAnimation {
                    showVerificationField = true
                        resendTimer = 60
                        canResend = false
                    }
                }
            } catch {
                print("🔥 ERROR: Failed to send verification code: \(error)")
                print("🔥 ERROR: Error details: \(error.localizedDescription)")
                
                // Ensure we're on main thread for UI updates
                await MainActor.run {
                    authManager.errorMessage = "Failed to send verification code: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func verifyCode() {
        guard let verificationID = verificationID else { return }
        
        Task {
            do {
                try await authManager.verifyCode(verificationID: verificationID, code: verificationCode)
            } catch {
                print("Error verifying code: \(error)")
            }
        }
    }
    
    private func resendCode() {
        isResendingCode = true
        verificationCode = ""
        
        Task {
            do {
                let fullPhoneNumber = selectedCountry.dialCode + phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                verificationID = try await authManager.startPhoneVerification(phoneNumber: fullPhoneNumber)
                await MainActor.run {
                    resendTimer = 60
                    canResend = false
                    isResendingCode = false
                }
            } catch {
                await MainActor.run {
                    isResendingCode = false
                }
                print("Error resending verification code: \(error)")
            }
        }
    }
    
    private func goBack() {
        withAnimation {
            showVerificationField = false
            verificationCode = ""
            verificationID = nil
            authManager.errorMessage = nil
        }
    }
    
    // MARK: - Debug Functions
    #if DEBUG
    private func testFirebaseConfiguration() async {
        print("🔧 DEBUG: Testing Firebase configuration...")
        
        // Test 1: Check if Firebase app exists
        if let app = FirebaseApp.app() {
            print("✅ Firebase app exists: \(app.name)")
        } else {
            print("❌ Firebase app is nil")
            return
        }
        
        // Test 2: Check Auth instance
        let auth = Auth.auth()
        print("✅ Auth instance created")
        print("🔧 Auth app: \(auth.app?.name ?? "nil")")
        
        // Test 3: Check PhoneAuthProvider
        let provider = PhoneAuthProvider.provider()
//	//        print("🔧 Provider auth: \(provider.auth.app?.name ?? "nil")")
        
        // Test 4: Try a simple phone verification (should fail gracefully)
        do {
            print("🔧 Testing phone verification with dummy number...")
            let _ = try await provider.verifyPhoneNumber("+1234567890", uiDelegate: nil)
            print("⚠️ Unexpected success with dummy number")
        } catch {
            print("✅ Expected error with dummy number: \(error.localizedDescription)")
        }
    }
    #endif
    
    // MARK: - Helper Functions
    private func formatPhoneNumber(_ number: String) -> String {
        let cleanedNumber = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if selectedCountry.code == "US" {
            // Format US numbers as (XXX) XXX-XXXX
            if cleanedNumber.count <= 3 {
                return cleanedNumber
            } else if cleanedNumber.count <= 6 {
                let areaCode = String(cleanedNumber.prefix(3))
                let middle = String(cleanedNumber.dropFirst(3))
                return "(\(areaCode)) \(middle)"
            } else {
                let areaCode = String(cleanedNumber.prefix(3))
                let middle = String(cleanedNumber.dropFirst(3).prefix(3))
                let last = String(cleanedNumber.dropFirst(6).prefix(4))
                return "(\(areaCode)) \(middle)-\(last)"
            }
        } else {
            // For other countries, just return the cleaned number
            return cleanedNumber
        }
    }
}

// MARK: - Text Field Styles (matching original)
struct CompactTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .font(.system(size: 15))
    }
}

// MARK: - Country Picker View
struct CountryPickerView: View {
    @Binding var selectedCountry: CountryCode
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private let countries = [
        CountryCode(name: "United States", code: "US", dialCode: "+1", flag: "🇺🇸"),
        CountryCode(name: "Canada", code: "CA", dialCode: "+1", flag: "🇨🇦"),
        CountryCode(name: "United Kingdom", code: "GB", dialCode: "+44", flag: "🇬🇧"),
        CountryCode(name: "Australia", code: "AU", dialCode: "+61", flag: "🇦🇺"),
        CountryCode(name: "Germany", code: "DE", dialCode: "+49", flag: "🇩🇪"),
        CountryCode(name: "France", code: "FR", dialCode: "+33", flag: "🇫🇷"),
        CountryCode(name: "Japan", code: "JP", dialCode: "+81", flag: "🇯🇵"),
        CountryCode(name: "South Korea", code: "KR", dialCode: "+82", flag: "🇰🇷"),
        CountryCode(name: "India", code: "IN", dialCode: "+91", flag: "🇮🇳"),
        CountryCode(name: "China", code: "CN", dialCode: "+86", flag: "🇨🇳"),
        CountryCode(name: "Brazil", code: "BR", dialCode: "+55", flag: "🇧🇷"),
        CountryCode(name: "Mexico", code: "MX", dialCode: "+52", flag: "🇲🇽"),
    ]
    
    private var filteredCountries: [CountryCode] {
        if searchText.isEmpty {
            return countries
        } else {
            return countries.filter { country in
                country.name.localizedCaseInsensitiveContains(searchText) ||
                country.dialCode.contains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                // Country List
                List(filteredCountries, id: \.code) { country in
                    Button(action: {
                        selectedCountry = country
                        dismiss()
                    }) {
                        HStack {
                            Text(country.flag)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(country.name)
                                    .foregroundColor(.primary)
                                Text(country.dialCode)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedCountry.code == country.code {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.purple)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search countries", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview("Phone Auth - Initial") {
    PhoneAuthView()
        .environmentObject(AuthManager.mockUnauthenticated as! AuthManager)
}

#Preview("Phone Auth - Verification") {
    PhoneAuthView()
        .onAppear {
            // Note: This preview shows the initial state
            // To see verification state, manually trigger it in the running app
        }
        .environmentObject(AuthManager.mockUnauthenticated as! AuthManager)
}

#Preview("Phone Auth - Loading") {
    PhoneAuthView()
        .environmentObject({
            let auth = AuthManager.mockUnauthenticated as! MockAuthManager
            auth.isLoading = true
            return auth as! AuthManager
        }())
}

#Preview("Phone Auth - Error") {
    PhoneAuthView()
        .environmentObject({
            let auth = AuthManager.mockUnauthenticated as! MockAuthManager
            auth.errorMessage = "Invalid phone number format. Please check and try again."
            return auth as! AuthManager
        }())
}
