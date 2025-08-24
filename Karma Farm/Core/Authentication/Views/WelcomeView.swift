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
            VStack(spacing: 20) {
                // Primary sign up options
                VStack(spacing: 8) {
                    // Phone Sign Up Button - PRIMARY
                    Button(action: { showPhoneSignUp = true }) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Continue with Phone")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.purple)
                        .cornerRadius(12)
                    }
                    
                    // Email alternative - subtle
                    Button(action: { showEmailSignUp = true }) {
                        Text("Use email instead")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Sign In Link - separated
                Button(action: { isSignInMode = true }) {
                    Text("Already have an account? Sign In")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.purple)
                }
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
