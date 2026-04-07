import SwiftUI

struct TimezoneRowView: View {
    let row: TimezoneRowDisplay
    let isManaging: Bool
    let selection: Binding<Date>
    let onDateTap: () -> Void
    let onTimeTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(row.id)
                        .font(.headline)
                        .accessibilityIdentifier("timezone.row.\(row.id.accessibilitySlug)")

                    HStack(spacing: 8) {
                        if row.isSystemTimeZone {
                            TimezoneBadge(label: "Local")
                        }

                        if row.isReferenceTimeZone {
                            TimezoneBadge(label: "Reference")
                        }

                        Text(row.utcOffsetText)
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            HStack(spacing: 12) {
                if row.isEditingDate {
                    DatePicker(
                        "Date",
                        selection: selection,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .environment(\.timeZone, row.timeZone)
                    .environment(\.locale, Locale(identifier: "en_GB"))
                    .accessibilityIdentifier("timezone.date-picker.\(row.id.accessibilitySlug)")
                } else {
                    TimezoneFieldButton(
                        label: "Date",
                        value: row.dateText,
                        action: onDateTap
                    )
                    .disabled(isManaging)
                    .accessibilityIdentifier("timezone.date.\(row.id.accessibilitySlug)")
                }

                if row.isEditingTime {
                    DatePicker(
                        "Time",
                        selection: selection,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .environment(\.timeZone, row.timeZone)
                    .environment(\.locale, Locale(identifier: "en_GB"))
                    .accessibilityIdentifier("timezone.time-picker.\(row.id.accessibilitySlug)")
                } else {
                    TimezoneFieldButton(
                        label: "Time",
                        value: row.timeText,
                        action: onTimeTap
                    )
                    .disabled(isManaging)
                    .accessibilityIdentifier("timezone.time.\(row.id.accessibilitySlug)")
                }
            }
        }
        .padding(.vertical, 6)
    }
}

private struct TimezoneFieldButton: View {
    let label: String
    let value: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.headline.monospacedDigit())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

private struct TimezoneBadge: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.thinMaterial, in: Capsule())
    }
}

private extension String {
    var accessibilitySlug: String {
        unicodeScalars.map { scalar in
            CharacterSet.alphanumerics.contains(scalar) ? String(scalar) : "-"
        }
        .joined()
    }
}
