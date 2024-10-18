//
//  OpenAIAPIKeyOnboardingStep.swift
//  TemplateApplication
//
//  Created by Hafizh Rahmatdianto Yusuf on 17/10/24.
//

import SwiftUI
import SpeziOnboarding
import SpeziLLMOpenAI

struct OpenAIAPIKeyOnboardingStep: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath: OnboardingNavigationPath

    var body: some View {
        LLMOpenAIAPITokenOnboardingStep {
            onboardingNavigationPath.nextStep()  // Move to the next onboarding step
        }
    }
}
