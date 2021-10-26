//
//  NetworkMonitor.swift
//  CurrencyConverter
//
//  Created by Stefan Dojcinovic on 26.10.21..
//

import UIKit
import Network

class NetworkMonitor {
    //static let shared = NetworkMonitor()

    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }
    var isReachableOnCellular: Bool = true

    func startMonitoring(comletion: @escaping (Bool) -> Void) {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive

            if path.status == .satisfied {
                print("We're connected!")
                comletion(true)
            } else {
                print("No connection.")
                comletion(false)
            }
            print(path.isExpensive)
        }

        //let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: .main)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
