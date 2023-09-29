//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 03.04.2023.
//

import Foundation
import PostgresBridge
import Vapor

final class PostgreSQLBase {

    let provider: PostgreSQLProviderPrtcl

    init(provider: PostgreSQLProviderPrtcl) {
        self.provider = provider
    }

    init(_ app: Application) {
        self.provider = PostgreSQLProvider(app)
    }

    func dataBaseExist(dbName: String) throws -> Bool {
        let query = "SELECT 1 AS result FROM pg_database WHERE datname='\(dbName)'"
        return try provider.execute(query: query).count > 0
    }
    
    func dataBaseExist(dbName: String) async throws -> Bool {
        let query = "SELECT 1 AS result FROM pg_database WHERE datname='\(dbName)'"
        return try await provider.execute(query: query).count > 0
    }

    func dataBaseCreate(dbName: String) throws {
        if try dataBaseExist(dbName: dbName) { return }
        let query = "CREATE DATABASE \(dbName)"
        try provider.execute(query: query)
    }
    
    func dataBaseCreate(dbName: String) async throws {
        if try await dataBaseExist(dbName: dbName) { return }
        let query = "CREATE DATABASE \(dbName)"
        try await provider.execute(query: query)
    }

    func dataBaseDrop(dbName: String) throws {
        if try !dataBaseExist(dbName: dbName) { return }
        let query = "DROP DATABASE \(dbName)"
        try provider.execute(query: query)
    }
    
    func dataBaseDrop(dbName: String) async throws {
        if try await !dataBaseExist(dbName: dbName) { return }
        let query = "DROP DATABASE \(dbName)"
        try await provider.execute(query: query)
    }
}


// MARK: Implementation Connection to PostgreSQL
protocol PostgreSQLProviderPrtcl {

    @discardableResult
    func execute(query: String) throws -> [BridgesRow]
    
    @discardableResult
    func execute(query: String) async throws -> [BridgesRow]
}

extension DatabaseIdentifier {
    public static var postgresBase: DatabaseIdentifier {
        return PostgresDatabaseIdentifier(url: URL(string: "postgresql://\(PG_USER):\(PG_PSWD)@\(PG_HOST):\(PG_PORT)/postgres")!,
                                          maxConnectionsPerEventLoop: 1)!
    }
}

class PostgreSQLProvider: PostgreSQLProviderPrtcl {

    let app: Application

    init(_ app: Application) {
        self.app = app
    }

    @discardableResult
    func execute(query: String) throws -> [BridgesRow] {
        let result: [BridgesRow] = try SwifQL.raw(query).execute(on: .postgresBase, on: app).map { (res: BridgesExecutedResult) -> [BridgesRow] in
            res.rows
        }.wait()

        return result
    }
    
    @discardableResult
    func execute(query: String) async throws -> [BridgesRow] {
        try await SwifQL.raw(query).execute(on: .postgresBase, on: app).rows
    }
}
