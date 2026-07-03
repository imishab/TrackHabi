import SwiftUI

struct AddCategoryView: View {

    @State private var viewModel = AddCategoryViewModel()
    @Environment(\.dismiss) private var dismiss
    let onSave: (HabitCategory) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 6)

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Health, Work, Study", text: $viewModel.name)
                }

                Section("Icon") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(HabitPalette.icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title3)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle().fill(
                                        icon == viewModel.icon
                                            ? HabitPalette.color(named: viewModel.colorName).opacity(0.3)
                                            : Color.clear
                                    )
                                )
                                .onTapGesture { viewModel.icon = icon }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Color") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(HabitPalette.colorNames, id: \.self) { name in
                            Circle()
                                .fill(HabitPalette.color(named: name))
                                .frame(width: 32, height: 32)
                                .overlay {
                                    if name == viewModel.colorName {
                                        Circle().stroke(.white, lineWidth: 2)
                                    }
                                }
                                .onTapGesture { viewModel.colorName = name }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let category = viewModel.save() {
                            onSave(category)
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }
}

#Preview {
    AddCategoryView(onSave: { _ in })
}
