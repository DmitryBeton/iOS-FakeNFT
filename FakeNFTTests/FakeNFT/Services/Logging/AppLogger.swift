import Foundation
import os

enum AppLog {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "FakeNFT"

    static let network = Logger(subsystem: subsystem, category: "network")
    static let ui      = Logger(subsystem: subsystem, category: "ui")
}

