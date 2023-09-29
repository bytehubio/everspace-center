//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 04.04.2023.
//

import Foundation

actor ActorStat: GlobalActor {
    
    static let shared: ActorStat = .init()
    
    func methodUse(_ apiKey: String?,
                   _ network: String,
                   _ method: String,
                   _ apiType: Statistic.ApiType
    ) async {
        if let apiKey = apiKey {
            do {
                try await Statistic.updateOrCreate(apiKey, network, method, apiType)
            } catch {
                app.logger.warning("\(Self.self) \(#file) \(error.localizedDescription)")
            }
        }
    }
}

final class Stat {
    
    class func methodUse(_ apiKey: String?,
                         _ network: String,
                         _ method: String,
                         _ apiType: Statistic.ApiType
    ) {
        Task.detached {
            await ActorStat.shared.methodUse(apiKey, network, method, apiType)
        }
    }
}
