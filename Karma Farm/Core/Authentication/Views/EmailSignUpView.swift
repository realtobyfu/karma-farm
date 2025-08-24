import SwiftUI

struct EmailSignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @Binding var isSignInMode: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var agreeToTerms = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var currentStep: SignUpStep = .userInfo
    
    enum SignUpStep {
        case userInfo
        case credentials
        case verification
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(SignUpStep.allCases, id: \.self) { step in
                        Rectangle()
                            .fill(step.rawValue <= currentStep.rawValue ? Color.purple : Color(.systemGray4))
                            .frame(height: 4)
                            .cornerRadius(2)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image("Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                            
                            VStack(spacing: 8) {
                                Text(currentStep.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text(currentStep.subtitle)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 32)
                        
                        // Step content
                        switch currentStep {
                        case .userInfo:
                            userInfoStep
                        case .credentials:
                            credentialsStep
                        case .verification:
                            verificationStep
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 24)
                }
                
                // Bottom section
                VStack(spacing: 16) {
                    Divider()
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        if currentStep != .userInfo {
                            Button("Back") {
                                withAnimation {
                                    goToPreviousStep()
                                }
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.purple)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        Button(currentStep.buttonTitle) {
                            handleStepAction()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isStepValid ? Color.purple : Color.gray)
                        .cornerRadius(12)
                        .disabled(!isStepValid || authManager.isLoading)
                        .overlay(
                            Group {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                            }
                        )
                    }
                    
                    // Sign in link
                    Button("Already have an account? Sign In") {
                        dismiss()
                        isSignInMode = true
                    }
                    .underline()
                    .font(.system(size: 14))
                    .foregroundColor(.purple)
                    .padding(.bottom, 40)
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
            }
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
    
    // MARK: - Step Views
    
    @ViewBuilder
    private var userInfoStep: some View {
        VStack(spacing: 16) {
            TextField("First Name", text: $firstName)
                .textFieldStyle(SignUpTextFieldStyle())
                .textContentType(.givenName)
                .autocapitalization(.words)
            
            TextField("Last Name", text: $lastName)
                .textFieldStyle(SignUpTextFieldStyle())
                .textContentType(.familyName)
                .autocapitalization(.words)
            
            TextField("Email", text: $email)
                .textFieldStyle(SignUpTextFieldStyle())
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
        }
    }
    
    @ViewBuilder
    private var credentialsStep: some View {
        VStack(spacing: 16) {
            // Email (read-only)
            HStack {
                Text("Email:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(email)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Password field
            HStack {
                if showPassword {
                    TextField("Password", text: $password)
                        .textContentType(.newPassword)
                } else {
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                }
                
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Confirm password field
            HStack {
                if showConfirmPassword {
                    TextField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                } else {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
                
                Button(action: { showConfirmPassword.toggle() }) {
                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Password requirements
            PasswordRequirementsView(password: password, confirmPassword: confirmPassword)
            
            // Terms and conditions
            HStack(alignment: .top, spacing: 12) {
                Button(action: { agreeToTerms.toggle() }) {
                    Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                        .foregroundColor(agreeToTerms ? .purple : .secondary)
                        .font(.system(size: 20))
                }
                
                Text("I agree to the **Terms of Service** and **Privacy Policy**")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var verificationStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            VStack(spacing: 8) {
                Text("Check your email")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("We've sent a verification link to **\(email)**")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                Button("Open Email App") {
                    openEmailApp()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.purple)
                .cornerRadius(12)
                
                Button("Resend Email") {
                    resendVerificationEmail()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.purple)
            }
            
            Text("After verifying your email, you'll be able to sign in to your account.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
        }
    }
    
    // MARK: - Computed Properties
    
    private var isStepValid: Bool {
        switch currentStep {
        case .userInfo:
            return !firstName.isEmpty && !lastName.isEmpty && isValidEmail(email)
        case .credentials:
            return isValidPassword(password) && password == confirmPassword && agreeToTerms
        case .verification:
            return true
        }
    }
    
    // MARK: - Actions
    
    private func handleStepAction() {
        switch currentStep {
        case .userInfo:
            withAnimation {
                currentStep = .credentials
            }
        case .credentials:
            signUpWithEmail()
        case .verification:
            dismiss()
        }
    }
    
    private func goToPreviousStep() {
        switch currentStep {
        case .credentials:
            currentStep = .userInfo
        case .verification:
            currentStep = .credentials
        default:
            break
        }
    }
    
    private func signUpWithEmail() {
        Task {
            do {
                try await authManager.signUpWithEmail(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName
                )
                
                await MainActor.run {
                    withAnimation {
                        currentStep = .verification
                    }
                }
            } catch {
                // Error is handled by AuthManager
            }
        }
    }
    
    private func resendVerificationEmail() {
        Task {
            try await authManager.resendEmailVerification()
        }
    }
    
    private func openEmailApp() {
        if let url = URL(string: "mailto:") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Helper Functions
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8 &&
               password.contains(where: { $0.isUppercase }) &&
               password.contains(where: { $0.isLowercase }) &&
               password.contains(where: { $0.isNumber })
    }
}

// MARK: - Supporting Views

struct PasswordRequirementsView: View {
    let password: String
    let confirmPassword: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RequirementRow(
                text: "At least 8 characters",
                isMet: password.count >= 8
            )
            
            RequirementRow(
                text: "Contains uppercase letter",
                isMet: password.contains(where: { $0.isUppercase })
            )
            
            RequirementRow(
                text: "Contains lowercase letter",
                isMet: password.contains(where: { $0.isLowercase })
            )
            
            RequirementRow(
                text: "Contains number",
                isMet: password.contains(where: { $0.isNumber })
            )
            
            RequirementRow(
                text: "Passwords match",
                isMet: !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
            )
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
}

struct RequirementRow: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .secondary)
                .font(.system(size: 16))
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(isMet ? .primary : .secondary)
            
            Spacer()
        }
    }
}

struct SignUpTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .font(.system(size: 16))
    }
}

// MARK: - Extensions

extension EmailSignUpView.SignUpStep: CaseIterable {
    var rawValue: Int {
        switch self {
        case .userInfo: return 0
        case .credentials: return 1
        case .verification: return 2
        }
    }
    
    var title: String {
        switch self {
        case .userInfo: return "Welcome!"
        case .credentials: return "Create Account"
        case .verification: return "Verify Email"
        }
    }
    
    var subtitle: String {
        switch self {
        case .userInfo: return "Let's start by getting to know you"
        case .credentials: return "Create a secure password for your account"
        case .verification: return "We need to verify your email address"
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .userInfo: return "Continue"
        case .credentials: return "Create Account"
        case .verification: return "Done"
        }
    }
}

#Preview {
    EmailSignUpView(isSignInMode: .constant(false))
        .environmentObject(AuthManager.shared)
} 
