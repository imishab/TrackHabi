import SwiftUI

enum AddChoice {
    case habit
    case task
}

struct AddChoiceSheet: View {

    @Environment(\.dismiss) private var dismiss
    let onChoose: (AddChoice) -> Void

    var body: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            Text("What would you like to add?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            VStack(spacing: 12) {
                choiceRow(
                    title: "New Habit",
                    subtitle: "Something you repeat on a schedule",
                    icon: "checklist",
                    tint: .mint
                ) {
                    choose(.habit)
                }

                choiceRow(
                    title: "New Task",
                    subtitle: "A one-off to-do with a due date",
                    icon: "checkmark.circle",
                    tint: .blue
                ) {
                    choose(.task)
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
    }

    private func choose(_ choice: AddChoice) {
        dismiss()
        onChoose(choice)
    }

    private func choiceRow(title: String, subtitle: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundStyle(tint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            AddChoiceSheet(onChoose: { _ in })
        }
}
