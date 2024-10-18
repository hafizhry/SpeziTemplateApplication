import SpeziLLM
import SpeziLLMOpenAI
import SwiftUI

// Message struct to define each chat message
struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool  // True if it's a user message, false if it's from the assistant
}

// Subview for displaying a user message
struct UserMessageView: View {
    let content: String

    var body: some View {
        HStack {
            Spacer()
            Text(content)
                .padding()
                .background(Color.green.opacity(0.8))
                .cornerRadius(16)
                .foregroundColor(.white)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

// Subview for displaying an assistant (GPT) message
struct AssistantMessageView: View {
    let content: String

    var body: some View {
        HStack {
            Text(content)
                .padding()
                .background(Color.gray.opacity(0.8))
                .cornerRadius(16)
                .foregroundColor(.white)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
    }
}

// Main chat view that handles user input and displaying messages
struct LLMOpenAIDemoView: View {
    @Environment(LLMRunner.self) var runner  // Access the LLMRunner
    @State var messages: [Message] = []  // Store the conversation history
    @State var userInput: String = ""    // Store the user's input

    var body: some View {
        VStack {
            // Display the chat messages
            ScrollView {
                ForEach(messages) { message in
                    if message.isUser {
                        UserMessageView(content: message.content)  // User message
                    } else {
                        AssistantMessageView(content: message.content)  // Assistant message
                    }
                }
            }
            .padding(.top)

            // Input area for user to type a message
            HStack {
                TextField("Type a message...", text: $userInput)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)

                Button(action: {
                    Task {
                        await sendMessage()
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .padding()
                        .background(Color.green)
                        .cornerRadius(16)
                        .foregroundColor(.white)
                        .accessibilityLabel("Send Message")
                }
            }
            .padding()
        }
        .onAppear {
            // Add an initial message from the assistant when the view first appears
            messages.append(Message(content: "How do you feel today?", isUser: false))
        }
    }

    // Send a message and get a response from GPT
    func sendMessage() async {
        // Add user message to the conversation
        messages.append(Message(content: userInput, isUser: true))
        
        // Clear the input field
        let userMessage = userInput
        userInput = ""
        
        // Retrieve the OpenAI API key from localized strings
        let apiKey = String(localized: "GPT_API_KEY")
        
        // Instantiate the OpenAI LLM session
        let llmSession: LLMOpenAISession = runner(
            with: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: "You're a helpful assistant that answers questions from users.",
                    overwritingToken: apiKey  // Use your actual OpenAI API key
                )
            )
        )
        
        // Append user input to the LLM session context
        llmSession.context.append(userInput: userMessage)
        
        // Perform inference and add assistant response
        do {
            var assistantResponse = ""
            for try await token in try await llmSession.generate() {
                assistantResponse.append(token)
            }
            
            // Add assistant response to the conversation
            messages.append(Message(content: assistantResponse, isUser: false))
        } catch {
            // Handle errors (you can also display an error message in the chat)
            messages.append(Message(content: "Error: \(error.localizedDescription)", isUser: false))
        }
    }
}


#if DEBUG
struct LLMOpenAIDemoView_Previews: PreviewProvider {
    static var previews: some View {
        LLMOpenAIDemoView()
            .previewWith(standard: TemplateApplicationStandard()) {
                TemplateApplicationScheduler()
            }
    }
}
#endif
