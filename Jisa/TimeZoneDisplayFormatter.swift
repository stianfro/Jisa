import Foundation

struct TimeZoneDisplayFormatter {
    private let locale = Locale(identifier: "en_GB")
    private let calendar = Calendar(identifier: .gregorian)

    func dateString(for date: Date, in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }

    func timeString(for date: Date, in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func utcOffsetString(for timeZone: TimeZone, at date: Date) -> String {
        let totalSeconds = timeZone.secondsFromGMT(for: date)
        let sign = totalSeconds >= 0 ? "+" : "-"
        let absoluteSeconds = abs(totalSeconds)
        let hours = absoluteSeconds / 3600
        let minutes = (absoluteSeconds % 3600) / 60

        return String(format: "%@%02d:%02d", sign, hours, minutes)
    }

    func relativeDescription(from now: Date, to target: Date) -> String {
        let difference = Int(target.timeIntervalSince(now))
        let absoluteMinutes = abs(difference) / 60

        guard absoluteMinutes > 0 else {
            return "Now"
        }

        let days = absoluteMinutes / (24 * 60)
        let hours = (absoluteMinutes % (24 * 60)) / 60
        let minutes = absoluteMinutes % 60

        let components = [
            componentString(value: days, singular: "day"),
            componentString(value: hours, singular: "hour"),
            componentString(value: minutes, singular: "minute")
        ].compactMap { $0 }

        let description = join(components)
        return difference >= 0 ? "In \(description)" : "\(description) ago"
    }

    private func componentString(value: Int, singular: String) -> String? {
        guard value > 0 else {
            return nil
        }

        let noun = value == 1 ? singular : "\(singular)s"
        return "\(value) \(noun)"
    }

    private func join(_ components: [String]) -> String {
        switch components.count {
        case 0:
            return "Now"
        case 1:
            return components[0]
        case 2:
            return components.joined(separator: " and ")
        default:
            return "\(components.dropLast().joined(separator: ", ")) and \(components.last!)"
        }
    }
}
