//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziFirebaseAccount
import SpeziHealthKit
import SpeziOnboarding
import SpeziScheduler
import SwiftUI


/// Displays a multi-step onboarding flow for the Spezi Template Application.
struct OnboardingFlow: View {
    @Environment(HealthKit.self) private var healthKitDataSource
    @Environment(TemplateApplicationScheduler.self) private var scheduler

    @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false
    
    @State private var localNotificationAuthorization = false
    
    
    @MainActor private var healthKitAuthorization: Bool {
        // As HealthKit not available in preview simulator
        if ProcessInfo.processInfo.isPreviewSimulator {
            return false
        }
        
        return healthKitDataSource.authorized
    }
    
    
    var body: some View {
        OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
            Welcome()
            InterestingModules()
            
            if !FeatureFlags.disableFirebase {
                AccountOnboarding()
            }
            
            #if !(targetEnvironment(simulator) && (arch(i386) || arch(x86_64)))
                Consent()
            #endif
            
            if HKHealthStore.isHealthDataAvailable() && !healthKitAuthorization {
                HealthKitPermissions()
            }
            
            if !localNotificationAuthorization {
                NotificationPermissions()
            }
            
            // Add the OpenAI API Key Onboarding Step
            OpenAIAPIKeyOnboardingStep()
        }
            .task {
                localNotificationAuthorization = await scheduler.localNotificationAuthorization
            }
            .interactiveDismissDisabled(!completedOnboardingFlow)
    }
}


#if DEBUG
#Preview {
    OnboardingFlow()
        .previewWith(standard: TemplateApplicationStandard()) {
            OnboardingDataSource()
            HealthKit()
            AccountConfiguration(service: InMemoryAccountService())

            TemplateApplicationScheduler()
        }
}
#endif
