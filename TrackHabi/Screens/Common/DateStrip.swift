import SwiftUI

struct DateStrip: View {

    let dates: [Date]
    let selectedDate: Date
    let calendar: Calendar
    let onSelect: (Date) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(dates, id: \.self) { date in
                        DayChip(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                onSelect(date)
                            }
                        }
                        .id(date)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .onAppear {
                let target = dates.first { calendar.isDate($0, inSameDayAs: selectedDate) } ?? dates.last
                proxy.scrollTo(target, anchor: .center)
            }
        }
    }
}

private struct DayChip: View {

    let date: Date
    let isSelected: Bool
    let action: () -> Void

    private var isToday: Bool { Calendar.current.isDateInToday(date) }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isSelected ? .white : .secondary)
                Text(date.formatted(.dateTime.day()))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(width: 44, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.12))
            )
            .overlay {
                if isToday && !isSelected {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.accentColor, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
