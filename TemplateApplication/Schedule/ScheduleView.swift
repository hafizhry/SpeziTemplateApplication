//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
@_spi(TestingSupport) import SpeziAccount
import SpeziQuestionnaire
import SpeziScheduler
import SwiftUI


struct ScheduleView: View {
    @Environment(TemplateApplicationStandard.self) private var standard
    @Environment(TemplateApplicationScheduler.self) private var scheduler
    @Environment(Account.self) private var account: Account?

    @State private var presentedContext: EventContext?
    @Binding private var presentingAccount: Bool
    
    
    @MainActor private var eventContextsByDate: OrderedDictionary<Date, [EventContext]> {
        let eventContexts = scheduler.tasks.flatMap { task in
            task
                .events(
                    from: Calendar.current.startOfDay(for: .now),
                    to: .numberOfEventsOrEndDate(100, .now)
                )
                .map { event in
                    EventContext(event: event, task: task)
                }
        }
            .sorted()

        return OrderedDictionary(grouping: eventContexts) { eventContext in
            Calendar.current.startOfDay(for: eventContext.event.scheduledAt)
        }
    }

    
    var body: some View {
        NavigationStack {
            let eventContextsByDate = eventContextsByDate
            List(eventContextsByDate.keys, id: \.timeIntervalSinceNow) { startOfDay in
                Section(format(startOfDay: startOfDay)) {
                    ForEach(eventContextsByDate[startOfDay] ?? [], id: \.event) { eventContext in
                        EventContextView(eventContext: eventContext)
                            .onTapGesture {
                                if !eventContext.event.complete {
                                    presentedContext = eventContext
                                }
                            }
                    }
                }
            }
                .sheet(item: $presentedContext) { presentedContext in
                    destination(withContext: presentedContext)
                }
                .toolbar {
                    if account != nil {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
                .navigationTitle("SCHEDULE_LIST_TITLE")
        }
    }
    
    
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
    

    @MainActor
    private func destination(withContext eventContext: EventContext) -> some View {
        @ViewBuilder var destination: some View {
            switch eventContext.task.context {
            case let .questionnaire(questionnaire):
                QuestionnaireView(questionnaire: questionnaire) { result in
                    presentedContext = nil

                    guard case let .completed(response) = result else {
                        return // user cancelled the task
                    }

                    eventContext.event.complete(true)
                    await standard.add(response: response)
                }
            case let .test(string):
                ModalView(text: string, buttonText: String(localized: "CLOSE")) {
                    eventContext.event.complete(true)
                }
            }
        }
        return destination
    }
    
    
    private func format(startOfDay: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: startOfDay)
    }
}


#if DEBUG
#Preview("ScheduleView") {
    ScheduleView(presentingAccount: .constant(false))
        .previewWith(standard: TemplateApplicationStandard()) {
            TemplateApplicationScheduler()
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
