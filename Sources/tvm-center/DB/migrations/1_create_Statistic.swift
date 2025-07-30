//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.04.2023.
//

import Foundation
import Fluent
import FluentPostgresDriver


struct Сreate_Statistic_1: AsyncMigration {
    
    private let className = Statistic.self
    
    func prepare(on database: Database) async throws {
        try await database.transaction { database in
            try await database.schema(className.schema)
                .field(.id, .int64, .identifier(auto: true))
                .field(.string("api_key"), .string, .required)
                .field(.string("network"), .string, .sql(.default("")), .required)
                .field(.string("method"), .string, .sql(.default("")), .required)
                .field(.string("api_type"), .string, .required)
                .field(.string("count"), .string, .sql(.default(0)), .required)
            
                .field(.string("updated_at"), .datetime)
                .field(.string("created_at"), .datetime)
                .unique(on: .string("api_key"), .string("network"), .string("method"), .string("api_type"))
                .create()
        }
    }
    
    func revert(on database: Database) async throws {
        try await database.transaction { database in
            try await database.schema(className.schema).delete()
        }
    }
}


//struct Сreate_Statistic_1: TableMigration {    
//    typealias Table = Statistic
//
//    static func prepare(on conn: BridgeConnection) async throws {
//        let builder: CreateTableBuilder<Table> = createBuilder
//        _ = builder.column("id", .bigserial, .primaryKey, .notNull)
//        _ = builder.column("api_key", .text, .notNull)
//        _ = builder.column("network", .text, .default(""), .notNull)
//        _ = builder.column("method", .text, .default(""), .notNull)
//        _ = builder.column("api_type", .text, .notNull)
//        _ = builder.column("count", .bigint, .default(0), .notNull)
//        
//        _ = builder.column("created_at", .timestamptz, .default(Fn.now()), .notNull)
//        _ = builder.column("updated_at", .timestamptz, .default(Fn.now()), .notNull)
//
//        try await builder.execute(on: conn)
//    }
//
//    static func revert(on conn: BridgeConnection) async throws {
//        let builder: DropTableBuilder<Table> = dropBuilder
//        try await builder.execute(on: conn)
//    }
//}
