//
//  ConnectivityService.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 05.02.2026.
//

import Network

final class ConnectivityService {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ConnectivityMonitor.queue")
    
    private(set) var isOffline: Bool = false
    
    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isOffline = (path.status != .satisfied)
        }
        monitor.start(queue: queue)
    }
    
    func stop() {
        monitor.cancel()
    }
    
    func isOfflineNow() -> Bool {
        self.isOffline
    }
}
