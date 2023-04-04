//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.04.2023.
//

import Foundation
import PostgresBridge
import Vapor

final class Statistic: Table {
    
    @Column("id")
    var id: Int64
    
    @Column("api_key")
    var apiKey: String
    
    @Column("network")
    var network: String
    
    @Column("api_type")
    var apiType: ApiType
    
    @Column("method")
    var method: String
    
    @Column("count")
    var count: Int64
    
    @Column("created_at")
    public var createdAt: Date
    
    @Column("updated_at")
    public var updatedAt: Date
    
    /// See `Table`
    init() {}
    
    init(apiKey: String, network: String, method: String, apiType: ApiType, count: Int64, updatedAt: Date) {
        self.apiKey = apiKey
        self.network = network
        self.method = method
        self.apiType = apiType
        self.count = count
        self.updatedAt = updatedAt
    }
    
    enum ApiType: String, Codable {
        case queryParams
        case jsonRpc
    }
}


//// MARK: Queries
extension Statistic {
    
    @discardableResult
    static func updateOrCreate(_ apiKey: String,
                               _ network: String,
                               _ method: String,
                               _ apiType: ApiType,
                               _ count: Int64? = nil
    ) async throws -> Statistic {
        return try await app.postgres.transaction(to: .default) { conn in
            var statistic: Statistic!
            statistic = try await SwifQL.select(
                 \Statistic.$id,
                 \Statistic.$apiKey,
                 \Statistic.$network,
                 \Statistic.$method,
                 \Statistic.$apiType,
                 \Statistic.$count,
                 \Statistic.$updatedAt,
                 \Statistic.$createdAt
            ).from(Statistic.table)
                .where(\Statistic.$apiKey == apiKey &&
                        \Statistic.$network == network &&
                        \Statistic.$method == method &&
                        \Statistic.$apiType == apiType.rawValue
                )
                .execute(on: conn)
                .first(decoding: Statistic.self)
            
            if statistic == nil {
                statistic = .init(apiKey: apiKey, network: network, method: method, apiType: apiType, count: 1, updatedAt: Date())
                return try await statistic.insert(on: conn)
            } else {
                statistic.count += 1
                return try await statistic.upsert(conflictColumn: \Statistic.$id, on: conn)
            }
        }
    }
}
