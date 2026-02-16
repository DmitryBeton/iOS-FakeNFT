import Foundation

/// Общий helper для текстового timestamp в логах.
/// Формат: `HH:mm:ss.SSS`
enum LogTimestamp {
    private static let queue = DispatchQueue(label: "com.fakenft.log.timestamp")
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    static func current() -> String {
        queue.sync {
            formatter.string(from: Date())
        }
    }
}
