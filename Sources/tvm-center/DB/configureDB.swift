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

        try await migrations(app)
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
        throw AdvageError("DatabaseID \(defaultPostgresDatabaseID)")
    }

    try await db.createIfNeeded(dbName: dbName)
}


