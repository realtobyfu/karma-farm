import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        WelcomeView()
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthManager.shared)
} 
