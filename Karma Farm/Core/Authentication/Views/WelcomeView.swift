import SwiftUI

struct WelcomeView: View {
    @State private var showEmailSignUp = false
    @State private var showPhoneSignUp = false
    @State private var isSignInMode = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Logo and title section
            VStack(spacing: 24) {
                Spacer()
                
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                
                VStack(spacing: 8) {
                    Text("Welcome to Karma Farm")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Connect with your community and earn karma by helping others")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
            }
            .frame(maxHeight: .infinity)
            
            // Sign up options section
            VStack(spacing: 12) {
                // Email Sign Up Button
                Button(action: { showEmailSignUp = true }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("Continue with Email")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.purple)
                    .cornerRadius(12)
                }
                
                // Phone Sign Up Button
                Button(action: { showPhoneSignUp = true }) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("Continue with Phone")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.purple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.purple, lineWidth: 1)
                    )
                }
                
                // Divider with "or"
                HStack {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 1)
                    
                    Text("or")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 1)
                }
                .padding(.vertical, 8)
                
                // Sign In Button
                Button(action: { isSignInMode = true }) {
                    Text("Already have an account? Sign In")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.purple)
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 24)
            
            // Terms and Privacy
            VStack(spacing: 8) {
                Divider()
                
                Text("By continuing, you agree to our **Terms of Service** and **Privacy Policy**")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
            }
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showEmailSignUp) {
            EmailSignUpView(isSignInMode: $isSignInMode)
        }
        .sheet(isPresented: $showPhoneSignUp) {
            PhoneAuthView()
        }
        .fullScreenCover(isPresented: $isSignInMode) {
            SignInView(isPresented: $isSignInMode)
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthManager.shared)
} 