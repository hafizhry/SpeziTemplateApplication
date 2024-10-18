//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziScheduler
import SwiftUI


struct EventContextView: View {
    let eventContext: EventContext
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    if eventContext.event.complete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 30))
                            .accessibilityHidden(true)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(verbatim: eventContext.task.title)
                            .font(.headline)
                            .accessibilityLabel(
                                eventContext.event.complete
                                    ? "COMPLETED_TASK_LABEL \(eventContext.task.title)"
                                    : "TASK_LABEL \(eventContext.task.title)"
                            )
                        Text(verbatim: format(eventDate: eventContext.event.scheduledAt))
                            .font(.subheadline)
                    }
                }
                Divider()
                Text(eventContext.task.description)
                    .font(.callout)
                if !eventContext.event.complete {
                    Text(eventContext.task.context.actionType)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.top, 8)
                }
            }
        }
            .disabled(eventContext.event.complete)
            .contentShape(Rectangle())
    }
    
    
    private func format(eventDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: eventDate)
    }
}


#if DEBUG
#Preview(traits: .sizeThatFitsLayout) {
    let socialSupportTask = TemplateApplicationScheduler.socialSupportTask
    let testTask = TemplateApplicationScheduler.testTask
    let phq9Task = TemplateApplicationScheduler.phq9Task
    
    return VStack {
        // Preview for the socialSupportTask
        EventContextView(
            eventContext: EventContext(
                // We use a force unwrap in the preview as we can not recover from an error here
                // and the code will never end up in a production environment.
                // swiftlint:disable:next force_unwrapping
                event: socialSupportTask.events(from: .now.addingTimeInterval(-60 * 60 * 24)).first!,
                task: socialSupportTask
            )
        )
        .padding()
        
        // Preview for the testTask
        EventContextView(
            eventContext: EventContext(
                // We use a force unwrap in the preview as we can not recover from an error here
                // and the code will never end up in a production environment.
                // swiftlint:disable:next force_unwrapping
                event: testTask.events(from: .now.addingTimeInterval(-60 * 60 * 24)).first!,
                task: testTask
            )
        )
        .padding()
        
        // Preview for the phq9Task
        EventContextView(
            eventContext: EventContext(
                // We use a force unwrap in the preview as we can not recover from an error here
                // and the code will never end up in a production environment.
                // swiftlint:disable:next force_unwrapping
                event: phq9Task.events(from: .now.addingTimeInterval(-60 * 60 * 24)).first!,
                task: phq9Task
            )
        )
        .padding()
    }
}
#endif
