//
//  LocationPermissionView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI
import CoreLocation

struct LocationPermissionView: View {
    @Binding var canProceed: Bool
    let onContinue: () -> Void
    
    @State private var locationManager = CLLocationManager()
    @State private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.purple)
                
                VStack(spacing: 12) {
                    Text("Enable Location")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Find nearby opportunities to help and connect with your local community")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
            }
            .frame(maxHeight: .infinity)
            
            // Benefits section
            VStack(spacing: 16) {
                PermissionBenefitRow(
                    icon: "map.fill",
                    title: "Discover Local Posts",
                    description: "See help requests and offers in your area"
                )
                
                PermissionBenefitRow(
                    icon: "person.2.fill",
                    title: "Connect with Neighbors",
                    description: "Find people nearby who share your interests"
                )
                
                PermissionBenefitRow(
                    icon: "shield.fill",
                    title: "Safe & Secure",
                    description: "Your exact location is never shared with others"
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            
            // Action buttons
            VStack(spacing: 12) {
                Button(authorizationStatus == .notDetermined ? "Enable Location" : "Continue") {
                    if authorizationStatus == .notDetermined {
                        requestLocationPermission()
                    } else {
                        onContinue()
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.purple)
                .cornerRadius(12)
                
                if authorizationStatus == .notDetermined {
                    Button("Skip for Now") {
                        canProceed = true
                        onContinue()
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
        .onAppear {
            authorizationStatus = locationManager.authorizationStatus
            canProceed = authorizationStatus != .notDetermined
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            authorizationStatus = status
            canProceed = status != .notDetermined
        }
    }
    
    private func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

struct PermissionBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.purple)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    LocationPermissionView(canProceed: .constant(false)) {}
}

