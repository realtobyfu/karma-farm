//
//  OnboardingContainerView.swift
//  Karma Farm
//
//  Created by Tobias Fu on 6/17/25.
//

import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case profileSetup = 0
    case locationPermission = 1
    case badgeSetup = 2
    case complete = 3
    
    var title: String {
        switch self {
        case .profileSetup: return "Set Up Profile"
        case .locationPermission: return "Location Access"
        case .badgeSetup: return "Earn Badges"
        case .complete: return "Welcome!"
        }
    }
}

struct OnboardingContainerView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var currentStep: OnboardingStep = .profileSetup
    @State private var canProceed = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            ProgressIndicatorView(currentStep: currentStep)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            
            // Step content
            Group {
                switch currentStep {
                case .profileSetup:
                    ProfileSetupView(canProceed: $canProceed) {
                        moveToNextStep()
                    }
                case .locationPermission:
                    LocationPermissionView(canProceed: $canProceed) {
                        moveToNextStep()
                    }
                case .badgeSetup:
                    BadgeSetupView(canProceed: $canProceed) {
                        moveToNextStep()
                    }
                case .complete:
                    OnboardingCompleteView {
                        completeOnboarding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(.systemBackground))
    }
    
    private func moveToNextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep.rawValue < OnboardingStep.allCases.count - 1 {
                currentStep = OnboardingStep(rawValue: currentStep.rawValue + 1) ?? .complete
                canProceed = false
            }
        }
    }
    
    private func completeOnboarding() {
        // Mark onboarding as complete in user preferences
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // This will trigger the main app view since authentication is already handled
        authManager.objectWillChange.send()
    }
}

struct ProgressIndicatorView: View {
    let currentStep: OnboardingStep
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingStep.allCases.filter { $0 != .complete }, id: \.rawValue) { step in
                Rectangle()
                    .fill(step.rawValue <= currentStep.rawValue ? Color.purple : Color(.systemGray4))
                    .frame(height: 4)
                    .cornerRadius(2)
            }
        }
    }
}

struct OnboardingCompleteView: View {
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success animation placeholder
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                VStack(spacing: 8) {
                    Text("You're all set!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Welcome to the Karma Farm community. Start exploring and helping others!")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Spacer()
            
            // Complete button
            VStack(spacing: 16) {
                Button("Get Started") {
                    onComplete()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.purple)
                .cornerRadius(12)
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 34)
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(AuthManager.shared)
}

