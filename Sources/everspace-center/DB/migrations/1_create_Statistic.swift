//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.04.2023.
//

import Foundation
import Bridges

struct Сreate_Statistic_1: TableMigration {    
    typealias Table = Statistic

    static func prepare(on conn: BridgeConnection) async throws {
        let builder: CreateTableBuilder<Table> = createBuilder
        _ = builder.column("id", .bigserial, .primaryKey, .notNull)
        _ = builder.column("api_key", .text, .notNull)
        _ = builder.column("network", .text, .default(""), .notNull)
        _ = builder.column("method", .text, .default(""), .notNull)
        _ = builder.column("api_type", .text, .default(Statistic.ApiType.queryParams.rawValue), .notNull)
        _ = builder.column("count", .bigint, .default(0), .notNull)
        
        _ = builder.column("created_at", .timestamptz, .default(Fn.now()), .notNull)
        _ = builder.column("updated_at", .timestamptz, .default(Fn.now()), .notNull)

        try await builder.execute(on: conn)
    }

    static func revert(on conn: BridgeConnection) async throws {
        let builder: DropTableBuilder<Table> = dropBuilder
        try await builder.execute(on: conn)
    }
}
