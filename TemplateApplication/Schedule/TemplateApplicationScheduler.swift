//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziScheduler


/// A `Scheduler` using the ``TemplateApplicationTaskContext`` to schedule and manage tasks and events in the
/// Spezi Template Application.
typealias TemplateApplicationScheduler = Scheduler<TemplateApplicationTaskContext>


extension TemplateApplicationScheduler {
    static var socialSupportTask: SpeziScheduler.Task<TemplateApplicationTaskContext> {
        let dateComponents: DateComponents
        if FeatureFlags.testSchedule {
            // Adds a task at the current time for UI testing if the `--testSchedule` feature flag is set
            dateComponents = DateComponents(
                hour: Calendar.current.component(.hour, from: .now),
                minute: Calendar.current.component(.minute, from: .now)
            )
        } else {
            // For the normal app usage, we schedule the task for every day at 8:00 AM
            dateComponents = DateComponents(hour: 8, minute: 0)
        }

        return Task(
            title: String(localized: "TASK_SOCIAL_SUPPORT_QUESTIONNAIRE_TITLE"),
            description: String(localized: "TASK_SOCIAL_SUPPORT_QUESTIONNAIRE_DESCRIPTION"),
            schedule: Schedule(
                start: Calendar.current.startOfDay(for: Date()),
                repetition: .matching(dateComponents),
                end: .numberOfEvents(365)
            ),
            notifications: true,
            context: TemplateApplicationTaskContext.questionnaire(Bundle.main.questionnaire(withName: "SocialSupportQuestionnaire"))
        )
    }
    
    static var testTask: SpeziScheduler.Task<TemplateApplicationTaskContext> {
            let dateComponents: DateComponents
            if FeatureFlags.testSchedule {
                // Adds a task at the current time for UI testing if the `--testSchedule` feature flag is set
                dateComponents = DateComponents(
                    hour: Calendar.current.component(.hour, from: .now),
                    minute: Calendar.current.component(.minute, from: .now)
                )
            } else {
                // For the normal app usage, we schedule the task for every day at 10:00 AM
                dateComponents = DateComponents(hour: 10, minute: 0)
            }

            return Task(
                title: String(localized: "TEST_QUESTIONNAIRE_TITLE"),
                description: String(localized: "TEST_QUESTIONNAIRE_DESCRIPTION"),
                schedule: Schedule(
                    start: Calendar.current.startOfDay(for: Date()),
                    repetition: .matching(dateComponents),
                    end: .numberOfEvents(365)
                ),
                notifications: true,
                context: TemplateApplicationTaskContext.questionnaire(Bundle.main.questionnaire(withName: "TestQuestionnaire"))
            )
        }
    
    static var phq9Task: SpeziScheduler.Task<TemplateApplicationTaskContext> {
        let dateComponents: DateComponents
        if FeatureFlags.testSchedule {
            // Adds a task at the current time for UI testing if the `--testSchedule` feature flag is set
            dateComponents = DateComponents(
                hour: Calendar.current.component(.hour, from: .now),
                minute: Calendar.current.component(.minute, from: .now)
            )
        } else {
            // For the normal app usage, we schedule the task for every day at 10:00 AM, every 2 weeks
            dateComponents = DateComponents(hour: 10, minute: 0, weekday: 1) // Weekday can be set based on requirements
        }

        return Task(
            title: String(localized: "PHQ9_QUESTIONNAIRE_TITLE"),
            description: String(localized: "PHQ9_QUESTIONNAIRE_DESCRIPTION"),
            schedule: Schedule(
                start: Calendar.current.startOfDay(for: Date()),
                repetition: .matching(dateComponents),
                end: .numberOfEvents(26)
            ),
            notifications: true,
            context: TemplateApplicationTaskContext.questionnaire(Bundle.main.questionnaire(withName: "PHQ9Questionnaire"))
        )
    }

    /// Creates a default instance of the ``TemplateApplicationScheduler`` by scheduling the tasks listed below.
    convenience init() {
        self.init(tasks: [Self.socialSupportTask, Self.testTask, Self.phq9Task])
    }
}
