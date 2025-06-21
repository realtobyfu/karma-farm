import SwiftUI

enum SignInMethod {
    case email
    case phone
}

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isPresented: Bool
    
    @State private var signInMethod: SignInMethod = .email
    @State private var email = ""
    @State private var password = ""
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var verificationID: String?
    @State private var showPassword = false
    @State private var showVerificationField = false
    @State private var selectedCountry = CountryCode(name: "United States", code: "US", dialCode: "+1", flag: "🇺🇸")
    @State private var showCountryPicker = false
    @State private var showForgotPassword = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 24) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Sign in to your account")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Sign in method toggle
                VStack(spacing: 20) {
                    Picker("Sign In Method", selection: $signInMethod) {
                        Text("Email").tag(SignInMethod.email)
                        Text("Phone").tag(SignInMethod.phone)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 24)
                    
                    // Sign in form
                    if signInMethod == .email {
                        emailSignInForm
                    } else {
                        phoneSignInForm
                    }
                }
                
                Spacer()
                
                // Bottom section
                VStack(spacing: 16) {
                    Divider()
                    
                    Button("Don't have an account? Sign Up") {
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.purple)
                    .padding(.bottom, 34)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.purple)
                }
            }
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .alert("Error", isPresented: .constant(authManager.errorMessage != nil)) {
            Button("OK") {
                authManager.errorMessage = nil
            }
        } message: {
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Email Sign In Form
    
    @ViewBuilder
    private var emailSignInForm: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textFieldStyle(SignUpTextFieldStyle())
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
            
            HStack {
                if showPassword {
                    TextField("Password", text: $password)
                        .textContentType(.password)
                } else {
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                }
                
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    showForgotPassword = true
                }
                .font(.system(size: 14))
                .foregroundColor(.purple)
            }
            
            Button("Sign In") {
                signInWithEmail()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isValidEmailForm ? Color.purple : Color.gray)
            .cornerRadius(12)
            .disabled(!isValidEmailForm || authManager.isLoading)
            .overlay(
                Group {
                    if authManager.isLoading && signInMethod == .email {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                }
            )
            
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Phone Sign In Form
    
    @ViewBuilder
    private var phoneSignInForm: some View {
        VStack(spacing: 16) {
            if !showVerificationField {
                // Phone number input
                HStack(spacing: 0) {
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
                
                Button("Send Verification Code") {
                    sendVerificationCode()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isValidPhoneNumber ? Color.purple : Color.gray)
                .cornerRadius(12)
                .disabled(!isValidPhoneNumber || authManager.isLoading)
                .overlay(
                    Group {
                        if authManager.isLoading && signInMethod == .phone {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                    }
                )
                
            } else {
                // Verification code input
                VStack(spacing: 12) {
                    Text("Enter the 6-digit code sent to \(selectedCountry.dialCode) \(phoneNumber)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
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
                    
                    Button("Verify Code") {
                        verifyCode()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(verificationCode.count == 6 ? Color.purple : Color.gray)
                    .cornerRadius(12)
                    .disabled(verificationCode.count != 6 || authManager.isLoading)
                    
                    Button("Change Phone Number") {
                        withAnimation {
                            showVerificationField = false
                            verificationCode = ""
                            verificationID = nil
                            authManager.errorMessage = nil
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.purple)
                }
            }
            
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Computed Properties
    
    private var isValidEmailForm: Bool {
        isValidEmail(email) && !password.isEmpty
    }
    
    private var isValidPhoneNumber: Bool {
        let cleanedNumber = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return cleanedNumber.count >= 10
    }
    
    // MARK: - Actions
    
    private func signInWithEmail() {
        Task {
            do {
                try await authManager.signInWithEmail(email: email, password: password)
                await MainActor.run {
                    isPresented = false
                }
            } catch {
                // Error is handled by AuthManager
            }
        }
    }
    
    private func sendVerificationCode() {
        let fullPhoneNumber = selectedCountry.dialCode + phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        Task {
            do {
                verificationID = try await authManager.startPhoneVerification(phoneNumber: fullPhoneNumber)
                await MainActor.run {
                    withAnimation {
                        showVerificationField = true
                    }
                }
            } catch {
                // Error is handled by AuthManager
            }
        }
    }
    
    private func verifyCode() {
        guard let verificationID = verificationID else { return }
        
        Task {
            do {
                try await authManager.verifyCode(verificationID: verificationID, code: verificationCode)
                await MainActor.run {
                    isPresented = false
                }
            } catch {
                // Error is handled by AuthManager
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let cleanedNumber = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if selectedCountry.code == "US" {
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
            return cleanedNumber
        }
    }
}

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    VStack(spacing: 8) {
                        Text("Forgot Password?")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("Enter your email address and we'll send you a link to reset your password")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                if !showSuccessMessage {
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textFieldStyle(SignUpTextFieldStyle())
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        Button("Send Reset Link") {
                            sendResetLink()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isValidEmail(email) ? Color.purple : Color.gray)
                        .cornerRadius(12)
                        .disabled(!isValidEmail(email) || isLoading)
                        .overlay(
                            Group {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                            }
                        )
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Reset link sent!")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Check your email for the password reset link")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Done") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.purple)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
        }
    }
    
    private func sendResetLink() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            showSuccessMessage = true
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    SignInView(isPresented: .constant(true))
        .environmentObject(AuthManager.shared)
} 