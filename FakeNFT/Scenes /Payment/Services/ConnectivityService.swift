//
//  ConnectivityService.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 05.02.2026.
//

import Network
import Foundation

final class ConnectivityService {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ConnectivityMonitor.queue")
    private let stateLock = NSLock()

    private var isOffline: Bool = false

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.setOffline(path.status != .satisfied)
        }
        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }

    func isOfflineNow() -> Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        return isOffline
    }

    private func setOffline(_ value: Bool) {
        stateLock.lock()
        isOffline = value
        stateLock.unlock()
    }
}
