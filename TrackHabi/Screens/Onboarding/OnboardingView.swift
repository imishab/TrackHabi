import SwiftUI

struct OnboardingView: View {

    @State private var viewModel = OnboardingViewModel()
    @FocusState private var focusedField: Field?
    let onComplete: () -> Void

    private enum Field {
        case name, email
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Welcome to TrackHabi")
                    .font(.title2.weight(.bold))
                Text("What would you like to call you?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 12)

            VStack(spacing: 14) {
                TextField("Your name", text: $viewModel.name)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .email }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                TextField("Your email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.done)
                    .onSubmit { submit() }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }

            Button {
                submit()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSubmit)

            Spacer(minLength: 0)
        }
        .padding()
        .padding(.top, 8)
        .onAppear {
            focusedField = .name
        }
    }

    private func submit() {
        guard viewModel.canSubmit else { return }
        viewModel.submit()
        onComplete()
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
