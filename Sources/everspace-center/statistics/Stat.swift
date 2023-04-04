//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 04.04.2023.
//

import Foundation

final class Stat {
    
    class func methodUse(_ apiKey: String?,
                         _ network: String,
                         _ method: String,
                         _ apiType: Statistic.ApiType
    ) {
        Task {
            if let apiKey = apiKey {
                do {
                    try await Statistic.updateOrCreate(apiKey, network, method, apiType)
                } catch {
                    app.logger.warning("\(Self.self) \(#file) \(error.localizedDescription)")
                }
            }
        }
    }
}
