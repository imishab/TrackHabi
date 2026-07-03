import SwiftUI

struct EditProfileView: View {

    @State private var viewModel = EditProfileViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Name") {
                TextField("Your name", text: $viewModel.name)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
            }

            Section("Email") {
                TextField("Your email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.save()
                    dismiss()
                }
                .disabled(!viewModel.canSave)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
    }
}
