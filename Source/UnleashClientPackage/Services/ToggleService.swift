//
//  ToggleService.swift
//  Unleash
//
//  Copyright © 2019 Silvercar. All rights reserved.
//

import Foundation
import PromiseKit
#if canImport(PMKFoundation)
    import PMKFoundation
#endif

class ToggleService: ToggleServiceProtocol {
    enum Constants {
        static let successStatusCode = 200
    }

    private let appName: String
    private let instanceId: String
    private(set) var eTag = ""

    init(appName: String, instanceId: String) {
        self.appName = appName
        self.instanceId = instanceId
    }
}

protocol ToggleServiceProtocol {
    func fetchToggles(url: URL) -> Promise<Toggles>
}

extension ToggleService {
    func fetchToggles(url: URL) -> Promise<Toggles> {
        let togglesUrl = url.appendingPathComponent("client/features")
        return firstly {
            try URLSession.shared.dataTask(.promise, with: makeUrlRequest(url: togglesUrl)).validate()
        }.map {
            if
                let httpResponse = $0.response as? HTTPURLResponse,
                httpResponse.statusCode == Constants.successStatusCode,
                let eTag = httpResponse.allHeaderFields["Etag"] as? String,
                !eTag.isEmpty
            {
                self.eTag = eTag
            }
            return try JSONDecoder().decode(Toggles.self, from: $0.data)
        }
    }

    private func makeUrlRequest(url: URL) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appName, forHTTPHeaderField: "UNLEASH-APPNAME")
        request.addValue(instanceId, forHTTPHeaderField: "UNLEASH-INSTANCEID")
        request.addValue(appName, forHTTPHeaderField: "User-Agent")
        request.setValue(eTag, forHTTPHeaderField: "If-None-Match")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        return request
    }
}
