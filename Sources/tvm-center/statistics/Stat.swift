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
                Task {
                    do {
                        try await Statistic.updateOrCreate(apiKey: apiKey, network: network, method: method, apiType: apiType, db: app.db)
                    } catch {
                        
                    }
                }
//                try await Statistic.updateOrCreate(apiKey: apiKey, network: network, method: method, apiType: apiType, db: app.db)
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
