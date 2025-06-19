import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        PhoneAuthView()
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthManager.shared)
} 
