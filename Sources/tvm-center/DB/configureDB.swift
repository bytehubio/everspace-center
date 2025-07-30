//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.04.2023.
//

import Foundation
import Fluent
import FluentPostgresDriver
import Vapor
import PostgresKit

func configureDataBase(_ app: Application) async throws {
    do {
        app.databases.use(
            .postgres(
                configuration: .init(
                    hostname: PG_HOST,
                    port: PG_PORT,
                    username: PG_USER,
                    password: PG_PSWD,
                    database: PG_DB_NAME,
                    tls: PostgresConnection.Configuration.TLS.disable
                ),
                maxConnectionsPerEventLoop: PG_DB_CONNECTIONS,
                connectionPoolTimeout: .seconds(10),
                sqlLogLevel: .trace
            ),
            as: DatabaseID(string: "default"),
            isDefault: true
        )
        
        try await prepareDB(
            app: app,
            host: PG_HOST,
            port: PG_PORT,
            user: PG_USER,
            password: PG_PSWD,
            dbName: PG_DB_NAME
        )

        try await migrateDB(app: app)
    } catch {
        app.logger.critical("\(#function) \(#line) \(error.localizedDescription)")
    }
}


/// CHECK EXISTS OR CREATE DATABASE
private func prepareDB(app: Application, host: String, port: Int, user: String, password: String, dbName: String) async throws {
    let defaultPostgresDatabaseID: DatabaseID = .init(string: "postgres_default_db")
    
    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: host,
                port: port,
                username: user,
                password: password,
                database: "postgres",
                tls: PostgresConnection.Configuration.TLS.disable),
            maxConnectionsPerEventLoop: 1,
            connectionPoolTimeout: .seconds(10),
            sqlLogLevel: .trace
        ),
        as: defaultPostgresDatabaseID,
        isDefault: false
    )
    
    guard let db = app.databases.database(defaultPostgresDatabaseID, logger: app.logger, on: app.databases.eventLoopGroup.any()) as? SQLDatabase else {
        throw AppError("DatabaseID \(defaultPostgresDatabaseID)")
    }

    try await db.createIfNeeded(dbName: dbName)
}



func getDatabase(app: Application) throws -> any Database {
    guard let dataBase = app.databases.database(logger: app.logger, on: app.databases.eventLoopGroup.any()) else {
        throw AppError("Can not find default DataBase in App")
    }
    return dataBase
}


extension SQLDatabase {
    func exist(dbName: String) async throws -> Bool {
        try await raw("SELECT 1 AS result FROM pg_database WHERE datname='\(unsafeRaw: dbName)'").all().get().count > 0
    }
    
    @discardableResult
    func create(dbName: String) async throws -> [SQLRow] {
        try await raw("CREATE DATABASE \(unsafeRaw: dbName)").all().get()
    }
    
    @discardableResult
    func drop(dbName: String) async throws -> [SQLRow] {
        try await raw("DROP DATABASE IF EXIST \(unsafeRaw: dbName)").all().get()
    }
    
    @discardableResult
    func createIfNeeded(dbName: String) async throws -> [SQLRow] {
        if try await exist(dbName: dbName) { return [] }
        return try await create(dbName: dbName)
    }
}
