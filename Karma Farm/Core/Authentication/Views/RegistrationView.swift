//
//  RegistrationView.swift
//
//  Created by Tobias Fu on 1/5/24.
//

import SwiftUI

struct RegistrationView: View {
    @StateObject var viewModel = RegistrationViewModel()
    
    @Environment(\.dismiss) var dismiss


    var body: some View {
        VStack {
            Spacer()
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
 
            VStack{
                TextField("Enter your email", text: $viewModel.email)
                    .autocapitalization(.none)
                    .modifier(TextFieldModifier())

                SecureField("Enter your password", text: $viewModel.password)
                    .modifier(TextFieldModifier())

                TextField("Enter your full name", text: $viewModel.fullname)
                    .autocapitalization(.none)
                    .modifier(TextFieldModifier())
                
                TextField("Enter your username", text: $viewModel.username)
                    .autocapitalization(.none)
                    .modifier(TextFieldModifier())

            }
            .padding(.vertical)
             
            Button {
                // how we call an async function
                Task { try await viewModel.createUser() }
                
            } label: {
                Text("Sign Up")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 352, height: 44)
                    .background(Color("ButtonColor"))
                    .cornerRadius(8)
            }
            Spacer()
            
            Divider()
            Button {
                dismiss()
            } label: {
                HStack (spacing: 3) {
                    Text("Already have an account?")
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
                .font(.footnote)
                .foregroundColor(Color("TextColor"))
            }
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    RegistrationView()
}
