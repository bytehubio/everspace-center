//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.04.2023.
//

import Foundation
import Vapor
import VaporBridges
import PostgresBridge

///// Postgres config
extension DatabaseHost {
    public static var myDefaultHost: DatabaseHost {
        return .init(hostname: PG_HOST, port: PG_PORT, username: PG_USER, password: PG_PSWD, tlsConfiguration: nil)
    }
}

extension DatabaseIdentifier {
    public static var `default`: DatabaseIdentifier {
        return .init(name: PG_DB_NAME, host: .myDefaultHost, maxConnectionsPerEventLoop: PG_DB_CONNECTIONS)
    }
}
///// End Postgres config

func configureDataBase(_ app: Application) async throws {
    do {
        /// PostgreSQL config
        app.bridges.logger.logLevel = .error
        app.postgres.register(.init(host: DatabaseHost.myDefaultHost))
        
        let postgreSQLBase: PostgreSQLBase = .init(app)
        try await postgreSQLBase.dataBaseCreate(dbName: PG_DB_NAME)
        
        ///TEST REQUEST
    //    let aaa: PostgresQueryResult = try await app.postgres.connection(to: .default, { con in
    //        return try await con.query("SELECT datname FROM pg_database")
    //    })
        
        try await migrations(app)
    } catch {
        app.logger.critical("\(#function) \(#line) \(error.localizedDescription)")
    }
}
