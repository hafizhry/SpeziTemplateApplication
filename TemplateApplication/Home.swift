//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI


struct HomeView: View {
    enum Tabs: String {
        case schedule
        case openai
        case contact
    }

    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.schedule
    @State private var presentingAccount = false

    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Schedule Tab
            ScheduleView(presentingAccount: $presentingAccount)
                .tag(Tabs.schedule)
                .tabItem {
                    Label("SCHEDULE_TAB_TITLE", systemImage: "list.clipboard")
                }

            // LLM OpenAI Tab (New)
            LLMOpenAIDemoView()   // Adding the LLM OpenAI tab
                .tag(Tabs.openai)
                .tabItem {
                    Label("LLM_TAB_TITLE", systemImage: "brain.head.profile")
                }
            
            // Contacts Tab
            Contacts(presentingAccount: $presentingAccount)
                .tag(Tabs.contact)
                .tabItem {
                    Label("CONTACTS_TAB_TITLE", systemImage: "person.fill")
                }
            
        }
        .sheet(isPresented: $presentingAccount) {
            AccountSheet()
        }
        .accountRequired(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding) {
            AccountSheet()
        }
    }
}


#if DEBUG
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    
    return HomeView()
        .previewWith(standard: TemplateApplicationStandard()) {
            TemplateApplicationScheduler()
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}
#endif
