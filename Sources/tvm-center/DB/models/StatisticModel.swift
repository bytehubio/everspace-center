//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.04.2023.
//

import Foundation
import Fluent
import FluentPostgresDriver
import SwiftExtensionsPack

final class Statistic: Model, @unchecked Sendable {
    
    static var schema: String { "Statistic".lowercased() }
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int64?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Field(key: "api_key")
    var apiKey: String
    
    @Field(key: "network")
    var network: String
    
    @Field(key: "api_type")
    var apiType: String
    
    @Field(key: "method")
    var method: String
    
    @Field(key: "count")
    var count: Int64
    
    init() {}
    
    init(
        id: Int64? = nil,
        apiKey: String,
        network: String,
        method: String,
        apiType: ApiType,
        count: Int64
    ) {
        self.id = id
        self.apiKey = apiKey
        self.network = network
        self.method = method
        self.apiType = apiType.rawValue
        self.count = count
    }
    
    enum ApiType: String, Codable {
        case queryParams
        case jsonRpc
    }
}


//// MARK: Queries
extension Statistic {
    
//    static func create(
//        apiKey: String,
//        network: String,
//        method: String,
//        apiType: ApiType,
//        count: Int64,
//        db: any Database
//    ) async throws {
//        let object: Statistic = .init(
//            apiKey: apiKey,
//            network: network,
//            method: method,
//            apiType: apiType,
//            count: count
//        )
//        try await object.create(on: db)
//    }
    
    @discardableResult
    static func updateOrCreate(
        apiKey: String,
        network: String,
        method: String,
        apiType: ApiType,
        count: Int64? = nil,
        db: any Database
    ) async throws {
        let currentDate = Date()
        let formatter = baseDateFormater()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss+00"
        
        var query: SQLQueryString = "INSERT INTO \(unsafeRaw: Self.schema) (api_key, network, method, apiType, count, created_at, updated_at) VALUES "
        query.appendInterpolation(unsafeRaw: "('\(apiKey)', '\(network)', '\(method)', \(apiType.rawValue), \(count ?? 1), '\(formatter.string(from: currentDate))', '\(formatter.string(from: currentDate))')")
        query.appendInterpolation(unsafeRaw: " ")
        query.appendInterpolation(unsafeRaw: "ON CONFLICT (api_key, network, method, api_type) DO UPDATE SET ")
        query.appendInterpolation(unsafeRaw: "count = statistic.count + EXCLUDED.count, ")
        query.appendInterpolation(unsafeRaw: "updated_at = now();")
        
        guard let sqlDataBase = db as? SQLDatabase else { throw AdvageError("Not custing SQLDatabase") }
        try await sqlDataBase.raw(query).run()
    }
}
